/*============================================================================*/
/*
 * @file    tb_pattern_gen.v
 * @brief   Test pattern generator
 * @note    
 * @date    2020/11/28
 * @author  kingyo
 */
/*============================================================================*/
`timescale 1ns / 100ps

module tb_pattern_gen (
    input   wire            i_clk,
    input   wire            i_res_n,
    output  wire    [7:0]   o_ptn
);
    parameter LSB_POS = 10;

    reg     [31:0]  r_cnt;
    always @(posedge i_clk or negedge i_res_n) begin
        if (~i_res_n) begin
            r_cnt <= 32'd0;
        end else begin
            r_cnt <= r_cnt + 32'd1;
        end
    end

    assign o_ptn[7:0] = r_cnt[LSB_POS + 7:LSB_POS];

endmodule
