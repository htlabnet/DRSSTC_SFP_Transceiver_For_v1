/*============================================================================*/
/*
 * @file    serial_rx.v
 * @brief   Serial data recieve & decode module
 * @note    for Slave Device
 *           - Master Clock     : 60MHz
 *           - Serial Rate      : 20Mbps
 *           - Output Rate      : 2Mbps
 * @date    2023/10/16
 * @author  kingyo
 */
/*============================================================================*/

module serial_rx (
    input   wire            i_clk,
    input   wire            i_res_n,

    // Input serial data
    input   wire            i_SerialData,

    // SFP LOS input
    input   wire            i_sfp_los,

    // SFP receiver enable
    output  wire            o_rcv_en_n,

    input   wire    [3:0]   i_dip_sel,  // 0:前回値保持, 1:強制Low

    // Output data
    output  wire            o_my_lock,  // 自機のLock状態
    output  reg             o_rx_lock,  // フレームに内包されているLock状態
    output  reg     [3:0]   o_data,     //  {D4,D3,D2,D1}
    output  reg             o_master
);

    assign o_rcv_en_n = 1'b0;   // Always enable

    wire            w_sync1bData;
    wire            w_sync1bEn;

    // LOS input synchronizer
    reg     [1:0]   r_los_syncFF;
    wire            w_sfp_los = r_los_syncFF[1];
    always @(posedge i_clk or negedge i_res_n) begin
        if (~i_res_n) begin
            r_los_syncFF <= 2'b11;
        end else begin
            r_los_syncFF <= {r_los_syncFF[0], i_sfp_los};
        end
    end

    // CDR
    cdr cdr_inst (
        .i_clk ( i_clk ),
        .i_res_n ( i_res_n ),
        .i_SerialData ( i_SerialData ),
        .o_RecoveryData ( w_sync1bData ),
        .o_DataEn ( w_sync1bEn )
    );

    // 10bit shift register
    reg     [9:0]   r_10bShift;
    always @(posedge i_clk or negedge i_res_n) begin
        if (~i_res_n) begin
            r_10bShift <= 10'd0;
        end else if (w_sync1bEn) begin
            r_10bShift <= {r_10bShift[8:0], w_sync1bData};
        end
    end

    // Detect K28.5 code
    wire            w_k28_5_det = (r_10bShift == 10'b0011111010) | 
                                  (r_10bShift == 10'b1100000101);

    // Symbol lock
    reg     [3:0]   r_sym_bitCnt;
    wire            r_sym_capture = (r_sym_bitCnt == 4'd9);
    reg     [9:0]   r_sym_data;
    always @(posedge i_clk or negedge i_res_n) begin
        if (~i_res_n) begin
            r_sym_bitCnt <= 4'd0;
            r_sym_data <= 10'd0;
        end else if (w_sync1bEn) begin
            if (w_k28_5_det || r_sym_capture) begin
                r_sym_bitCnt <= 4'd0;
            end else begin
                r_sym_bitCnt <= r_sym_bitCnt + 4'd1;
            end

            if (r_sym_capture) begin
                r_sym_data <= r_10bShift;   // シンボルロックされたデータ
            end
        end
    end

    // Dispality & Error control
    wire            w_disp;
    reg             r_disp;
    wire            w_code_err;
    reg             r_code_err;
    wire            w_disp_err;
    reg             r_disp_err;
    always @(posedge i_clk or negedge i_res_n) begin
        if (~i_res_n) begin
            r_disp <= 1'b0;
            r_code_err <= 1'b1;
            r_disp_err <= 1'b1;
        end else begin
            if (r_sym_capture) begin
                r_disp <= w_disp;
                r_code_err <= w_code_err;
                r_disp_err <= w_disp_err;
            end
        end
    end

    // 8b10b decode
    wire    [7:0]   w_8b_data;
    decode_8b10b decode_8b10b (
        .datain ( r_sym_data[9:0] ),
        .dispin ( r_disp ),
        .dataout ( w_8b_data[7:0] ),
        .dispout ( w_disp ),
        .code_err ( w_code_err ),
        .disp_err ( w_disp_err )
    );

    // Symbol lock status
    // 5回連続でK28.5コードを検出した場合にロック状態へ遷移する
    // LOSアサート or 8b10bコードエラーで強制アンロック状態へ遷移
    reg             r_sym_locked;
    reg     [3:0]   r_sym_lock_cnt;
    always @(posedge i_clk or negedge i_res_n) begin
        if (~i_res_n) begin
            r_sym_locked <= 1'b0;
            r_sym_lock_cnt <= 4'd0;
        end else if (w_sfp_los | r_code_err) begin
            // ロックハズレ条件
            r_sym_locked <= 1'b0;
            r_sym_lock_cnt <= 4'd0;
        end else if (w_sync1bEn & r_sym_capture) begin
            if (w_k28_5_det) begin
                r_sym_lock_cnt <= r_sym_lock_cnt + 4'd1;
                if (r_sym_lock_cnt == 4'd4) begin
                    r_sym_locked <= 1'b1;
                end
            end else begin
                r_sym_lock_cnt <= 4'd0;
            end
        end
    end

    assign o_my_lock = r_sym_locked;    // 自機のロック状態出力

    reg             r_sym_capture_FF;
    reg             r_k28_5_det_FF;
    wire            w_out_trig = (~r_sym_capture & r_sym_capture_FF);
    always @(posedge i_clk or negedge i_res_n) begin
        if (~i_res_n) begin
            r_sym_capture_FF <= 1'b0;
            r_k28_5_det_FF <= 1'b0;
        end else begin
            r_sym_capture_FF <= r_sym_capture;
            r_k28_5_det_FF <= w_k28_5_det;
        end
    end

    // Parity Check
    wire            w_p1_ok = ^w_8b_data[7:0];

    // Output
    // アンロック時は出力強制Low
    always @(posedge i_clk or negedge i_res_n) begin
        if (~i_res_n) begin
            o_rx_lock <= 1'b0;
            o_data <= 4'd0;
            o_master <= 1'b0;
        end else if (~r_sym_locked) begin
            // ロックハズレ
            o_data[3] <= i_dip_sel[3] ? 1'b0 : o_data[3];
            o_data[2] <= i_dip_sel[2] ? 1'b0 : o_data[2];
            o_data[1] <= i_dip_sel[1] ? 1'b0 : o_data[1];
            o_data[0] <= i_dip_sel[0] ? 1'b0 : o_data[0];
        end else if (w_out_trig) begin
            // If K28.5
            if (r_k28_5_det_FF) begin
                // Do nothing.
            end else begin
                if (w_p1_ok & w_8b_data[7]) begin
                    o_rx_lock <= w_8b_data[6];
                    o_master <= w_8b_data[5];
                    o_data[3:0] <= w_8b_data[4:1];
                end else begin
                    o_data[3] <= i_dip_sel[3] ? 1'b0 : o_data[3];
                    o_data[2] <= i_dip_sel[2] ? 1'b0 : o_data[2];
                    o_data[1] <= i_dip_sel[1] ? 1'b0 : o_data[1];
                    o_data[0] <= i_dip_sel[0] ? 1'b0 : o_data[0];
                end
            end
        end
    end

endmodule
