/*============================================================================*/
/*
 * @file    cdr.v
 * @brief   Oversampling clock data recovery (CDR) module
 * @note    Serial data rate : i_clk / 3
 * @date    2023/10/16
 * @author  kingyo
 */
/*============================================================================*/

module cdr (
    input   wire            i_clk,
    input   wire            i_res_n,

    // Input Serial Data
    input   wire            i_SerialData,

    // Output Recovery Data
    output  reg             o_RecoveryData,
    output  reg             o_DataEn
);

    // Input data synchronizer
    reg     [2:0]   r_syncFF;
    always @(posedge i_clk or negedge i_res_n) begin
        if (~i_res_n) begin
            r_syncFF <= 3'd0;
        end else begin
            r_syncFF <= {r_syncFF[1:0], i_SerialData};
        end
    end

    // Detect data stream transitions
    wire            w_ts = r_syncFF[2] ^ r_syncFF[1];
    
    // Recovery Logic
    reg     [2:0]   r_rcvState;
    always @(posedge i_clk or negedge i_res_n) begin
        if (~i_res_n) begin
            r_rcvState <= 3'b001;
            o_RecoveryData <= 1'b0;
            o_DataEn <= 1'b0;
        end else begin
            // Update transition position
            if (w_ts) begin
                r_rcvState <= 3'b001;
            end else begin
                r_rcvState <= {r_rcvState[1:0], r_rcvState[2]};
            end

            // Capture data stream
            if (r_rcvState[1]) begin
                o_RecoveryData <= r_syncFF[2];
                o_DataEn <= 1'b1;
            end else begin
                o_DataEn <= 1'b0;
            end
        end
    end

endmodule
