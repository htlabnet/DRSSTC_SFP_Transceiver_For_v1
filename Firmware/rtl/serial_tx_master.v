/*============================================================================*/
/*
 * @file    serial_tx_master.v
 * @brief   Serial data transmitter module
 * @note    for Master Device
 *           - Master Clock     : 60MHz
 *           - Serial Rate      : 20Mbps
 *           - Sampling Rate    : 2Mbps
 * @date    2023/10/19
 * @author  kingyo
 */
/*============================================================================*/

module serial_tx_master (
    input   wire            i_clk,
    input   wire            i_res_n,
    input   wire            i_sfp_tx_flt,
    
    // Input data
    input   wire            i_my_lock,  // 自機ロック状態
    input   wire            i_rx_lock,  // 受信フレームロック状態
    input   wire    [3:0]   i_data,     // {D4,D3,D2,D1}
    input   wire            i_master,

    // Output data
    output  wire            o_SerialData,

    // Status
    output  wire            o_drv_en,
    output  wire            o_sfp_tx_dis_n
);

    parameter DEF_SMPL_CNT = 5'd29; // (60MHz / 2Mbps) - 1

    wire    w_start = 1'b1;         // Start bit (1)

    // Input Register
    reg             r_my_lock;
    reg             r_rx_lock;
    reg     [3:0]   r_data;
    reg             r_master;
    always @(posedge i_clk or negedge i_res_n) begin
        if (~i_res_n) begin
            r_my_lock <= 1'b0;
            r_rx_lock <= 1'b0;
            r_data <= 4'b0;
            r_master <= 1'b0;
        end else begin
            r_my_lock <= i_my_lock;
            r_rx_lock <= i_rx_lock;
            r_data <= i_data;
            r_master <= i_master;
        end
    end

    // Calc parity
    wire            w_p1 = w_start ^ r_my_lock ^ r_master ^ r_data[3] ^ r_data[2] ^ r_data[1] ^ r_data[0] ^ 1'b1;

    // MOSI Data
    wire    [7:0]   w_mosi_8b = {w_start, r_my_lock, r_master, r_data[3:0], w_p1};

    // Sampling Timing Gen
    reg     [4:0]   r_sample_prsc_cnt;
    wire            w_sample_prsc_en = (r_sample_prsc_cnt == DEF_SMPL_CNT); 
    always @(posedge i_clk or negedge i_res_n) begin
        if (~i_res_n) begin
            r_sample_prsc_cnt <= 5'd0;
        end else if (w_sample_prsc_en) begin
            r_sample_prsc_cnt <= 5'd0;
        end else begin
            r_sample_prsc_cnt <= r_sample_prsc_cnt + 5'd1;
        end
    end

    // Data Sampling
    reg     [7:0]   r_mosi_8b;
    always @(posedge i_clk or negedge i_res_n) begin
        if (~i_res_n) begin
            r_mosi_8b <= 8'd0;
        end else if (w_sample_prsc_en) begin
            r_mosi_8b <= w_mosi_8b;
        end
    end

    // Dispality Controll
    reg             r_dispin;
    wire            w_dispout;
    always @(posedge i_clk or negedge i_res_n) begin
        if (~i_res_n) begin
            r_dispin <= 1'b0;
        end else begin
            if (w_sample_prsc_en) begin
                r_dispin <= w_dispout;
            end
        end
    end

    // ロックシンボル送出制御
    // 自機がロックハズレ状態 or 受信フレームのLockがデサートされている場合にロックシンボルを5回送出する。
    // ロックシンボル送出後は5フレーム分は必ず通常データの送信に切り替える。
    reg             r_k28_5_send_en;
    reg     [3:0]   r_k28_5_send_cnt;
    reg     [1:0]   r_k28_5_send_status;    // 0:IDLE, 1:k28.5送信中, 3:通常データ送信中
    always @(posedge i_clk or negedge i_res_n) begin
        if (~i_res_n) begin
            r_k28_5_send_en <= 1'b0;
            r_k28_5_send_status <= 2'd0;
            r_k28_5_send_cnt <= 4'd0;
        end else begin
            if (w_sample_prsc_en) begin
                case (r_k28_5_send_status[1:0])
                    2'd0: begin
                        if (~r_rx_lock | ~r_my_lock) begin
                            r_k28_5_send_status <= 2'd1;
                            r_k28_5_send_en <= 1'b1;
                            r_k28_5_send_cnt <= 4'd0;
                        end
                    end

                    2'd1: begin
                        if (r_k28_5_send_cnt == 4'd4) begin
                            r_k28_5_send_cnt <= 4'd0;
                            r_k28_5_send_status <= 2'd2;
                            r_k28_5_send_en <= 1'b0;
                        end else begin
                            r_k28_5_send_cnt <= r_k28_5_send_cnt + 4'd1;
                        end
                    end

                    2'd2: begin
                        if (r_k28_5_send_cnt == 4'd4) begin
                            r_k28_5_send_cnt <= 4'd0;
                            r_k28_5_send_status <= 2'd0;
                        end else begin
                            r_k28_5_send_cnt <= r_k28_5_send_cnt + 4'd1;
                        end
                    end
                endcase
            end
        end
    end


    // 8b10b Encoder
    wire    [9:0]   w_data_10b;
    encode_8b10b encode_8b10b_inst (
        .datain ( {r_k28_5_send_en, r_k28_5_send_en ? 8'hbc : r_mosi_8b[7:0]} ),
        .dispin ( r_dispin ),
        .dataout ( w_data_10b ),
        .dispout ( w_dispout )
    );

    // Serialize Timing Gen
    reg     [2:0]   r_ser_prsc;
    wire            w_ser_en = r_ser_prsc[0];
    always @(posedge i_clk or negedge i_res_n) begin
        if (~i_res_n) begin
            r_ser_prsc <= 3'b001;
        end else begin
            r_ser_prsc <= {r_ser_prsc[1:0], r_ser_prsc[2]};
        end
    end

    // Encoder delay
    reg             r_sample_prsc_en_ff;
    always @(posedge i_clk or negedge i_res_n) begin
        if (~i_res_n) begin
            r_sample_prsc_en_ff <= 1'b0;
        end else begin
            r_sample_prsc_en_ff <= w_sample_prsc_en;
        end
    end

    // Serializer
    reg     [9:0]   r_tx_shiftreg;
    always @(posedge i_clk or negedge i_res_n) begin
        if (~i_res_n) begin
            r_tx_shiftreg <= 10'd0;
        end else if (w_ser_en) begin
            if (r_sample_prsc_en_ff) begin
                r_tx_shiftreg <= w_data_10b;
            end else begin
                r_tx_shiftreg <= {r_tx_shiftreg[8:0], 1'b0};
            end
        end
    end

    // Output register
    reg             r_serialData;
    always @(posedge i_clk or negedge i_res_n) begin
        if (~i_res_n) begin
            r_serialData <= 1'b0;
        end else begin
            r_serialData <= r_tx_shiftreg[9] & ~i_sfp_tx_flt;
        end
    end
    assign o_SerialData = r_serialData;

    // Driver
    assign o_drv_en = ~i_sfp_tx_flt;
    assign o_sfp_tx_dis_n = i_sfp_tx_flt;

endmodule
