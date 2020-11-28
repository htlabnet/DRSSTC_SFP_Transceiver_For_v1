/*============================================================================*/
/*
 * @file    serial_tx_master.v
 * @brief   Serial data transmitter module
 * @note    for Master Device
 * @date    2020/11/23
 * @author  kingyo
 */
/*============================================================================*/

module serial_tx_master (
    input   wire            i_clk,      // 40MHz
    input   wire            i_res_n,
    input   wire            i_sfp_tx_flt,
    
    // Input data
    input   wire            i_IsPro,
    input   wire            i_IsMaster,
    input   wire            i_RawPls,
    input   wire    [2:0]   i_Option,

    // Output data
    output  wire            o_SerialData,

    // Status
    output  wire            o_drv_en,
    output  wire            o_sfp_tx_dis_n,
    output  wire    [1:0]   o_tx_led
);

    // Input Register
    reg             r_IsPro;
    reg             r_IsMaster;
    reg             r_RawPls;
    reg     [2:0]   r_Option;
    always @(posedge i_clk or negedge i_res_n) begin
        if (~i_res_n) begin
            r_IsPro <= 1'b0;
            r_IsMaster <= 1'b0;
            r_RawPls <= 1'b0;
            r_Option <= 3'd0;
        end else begin
            r_IsPro <= i_IsPro;
            r_IsMaster <= i_IsMaster;
            r_RawPls <= i_RawPls;
            r_Option <= i_Option;
        end
    end

    // Calc parity
    wire            w_p1 = r_IsPro ^ r_IsMaster ^ r_RawPls;
    wire            w_p2 = ^r_Option[2:0];

    // MOSI Data
    wire    [7:0]   w_mosi_8b = {r_IsPro, r_IsMaster, r_RawPls, w_p1, r_Option[2:0], w_p2};

    // Sampling Timing Gen(1MSPS)
    reg     [5:0]   r_sample_prsc_cnt;
    wire            w_sample_prsc_en = (r_sample_prsc_cnt == 6'd39); 
    always @(posedge i_clk or negedge i_res_n) begin
        if (~i_res_n) begin
            r_sample_prsc_cnt <= 6'd0;
        end else if (w_sample_prsc_en) begin
            r_sample_prsc_cnt <= 6'd0;
        end else begin
            r_sample_prsc_cnt <= r_sample_prsc_cnt + 6'd1;
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

    // K28.5 insert
    reg     [7:0]   r_k28_5_cnt;
    wire            w_k28_5_en = (r_k28_5_cnt == 8'd0);
    always @(posedge i_clk or negedge i_res_n) begin
        if (~i_res_n) begin
            r_k28_5_cnt <= 8'd0;
        end else if (w_sample_prsc_en) begin
            r_k28_5_cnt <= r_k28_5_cnt + 8'd1;
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

    // 8b10b Encoder
    wire    [9:0]   w_data_10b;
    encode_8b10b encode_8b10b_inst (
        //.datain ( {1'b0, r_mosi_8b[7:0]} ),
        .datain ( {w_k28_5_en, w_k28_5_en ? 8'hbc : r_mosi_8b[7:0]} ),
        .dispin ( r_dispin ),
        .dataout ( w_data_10b ),
        .dispout ( w_dispout )
    );

    // Serialize Timing Gen(10Mbps)
    reg     [1:0]   r_ser_prsc;
    wire            w_ser_en = (r_ser_prsc == 2'd0);
    always @(posedge i_clk or negedge i_res_n) begin
        if (~i_res_n) begin
            r_ser_prsc <= 2'd0;
        end else begin
            r_ser_prsc <= r_ser_prsc + 2'd1;
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

    // TX LED
    assign o_tx_led[0] = i_sfp_tx_flt;  // Red
    assign o_tx_led[1] = ~i_sfp_tx_flt; // Green

    // Driver
    assign o_drv_en = ~i_sfp_tx_flt;
    assign o_sfp_tx_dis_n = i_sfp_tx_flt;

endmodule
