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

    // Output data
    output  reg             o_IsPro,
    output  reg             o_IsMaster,
    output  reg             o_RawPls,
    output  reg     [2:0]   o_Option,

    // Status LED
    output  wire    [1:0]   o_rx_led
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
                r_sym_data <= r_10bShift;
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
    // 256Byteに1回の頻度でK28.5を検出した場合のみロック
    // LOSアサート or 8b10bコードエラーで強制アンロック状態へ遷移
    reg             r_sym_locked;
    reg     [15:0]  r_k28_5_cnt;
    always @(posedge i_clk or negedge i_res_n) begin
        if (~i_res_n) begin
            r_sym_locked <= 1'b0;
            r_k28_5_cnt <= 16'hFFFF;
        end else if (w_sfp_los | r_code_err) begin
            r_sym_locked <= 1'b0;
            r_k28_5_cnt <= 16'hFFFF;
        end else if (w_sync1bEn) begin
            if (w_k28_5_det) begin
                r_k28_5_cnt <= 16'd0;
                if (r_k28_5_cnt == 16'h9ff) begin
                    r_sym_locked <= 1'b1;
                end else begin
                    r_sym_locked <= 1'b0;
                end
            end else begin
                if (r_k28_5_cnt != 16'hFFFF) begin
                    r_k28_5_cnt <= r_k28_5_cnt + 16'd1;
                end
            end

            if (r_k28_5_cnt > 16'h9ff) begin
                r_sym_locked <= 1'b0;
            end
        end
    end

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
    wire            w_p1_ok = ^w_8b_data[7:4];
    wire            w_p2_ok = ^w_8b_data[3:0];

    // Output
    // アンロック時は出力強制Low
    always @(posedge i_clk or negedge i_res_n) begin
        if (~i_res_n) begin
            o_IsPro <= 1'b0;
            o_IsMaster <= 1'b0;
            o_RawPls <= 1'b0;
            o_Option <= 3'd0;
        end else if (~r_sym_locked) begin
            o_RawPls <= 1'b0;
        end else if (w_out_trig) begin
            // If K28.5
            if (r_k28_5_det_FF) begin
                // Do nothing.
            end else begin
                if (w_p1_ok & w_p2_ok) begin
                    o_IsPro <= w_8b_data[7];
                    o_IsMaster <= w_8b_data[6];
                    o_RawPls <= w_8b_data[5];
                    o_Option <= w_8b_data[3:1];
                end else begin
                    o_RawPls <= 1'b0;
                end
            end
        end
    end

    // RX LED
    assign o_rx_led[0] = ~r_sym_locked; // Red
    assign o_rx_led[1] = o_RawPls;      // Green

endmodule
