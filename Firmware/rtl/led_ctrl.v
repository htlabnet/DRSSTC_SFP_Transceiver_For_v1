/*============================================================================*/
/*
 * @file    led_ctrl.v
 * @brief   LED control module
 * @note    
 * @date    2023/10/19
 * @author  kingyo
 */
/*============================================================================*/

module led_ctrl (
    input   wire            i_clk,
    input   wire            i_res_n,

    input   wire            i_tx_d1,
    input   wire            i_tx_err,
    input   wire            i_rx_d1,
    input   wire            i_rx_err,

    output  wire            o_tx_led_red,
    output  wire            o_tx_led_gr,
    output  wire            o_rx_led_red,
    output  wire            o_rx_led_gr
);

    // Boot表示（全点灯）信号生成
    reg     [25:0]  r_cnt_boot;
    reg     [ 1:0]  r_boot_st;
    wire            w_cnt_max_boot = (r_cnt_boot == 26'd59999999);
    always @(posedge i_clk or negedge i_res_n) begin
        if (~i_res_n) begin
            r_cnt_boot <= 26'd0;
            r_boot_st <= 2'd0;
        end else begin
            if (w_cnt_max_boot) begin
                r_cnt_boot <= 26'd0;
                if (r_boot_st != 2'b11) begin
                    r_boot_st <= r_boot_st + 2'd1;
                end
            end else begin
                r_cnt_boot <= r_cnt_boot + 26'd1;
            end
        end
    end

    // エラー表示用点滅信号生成（200ms ON, 200ms OFF）
    reg     [23:0]  r_cnt_flash;
    wire            w_cnt_max_flash = (r_cnt_flash == 24'd11999999);
    reg             r_flash_en;
    always @(posedge i_clk or negedge i_res_n) begin
        if (~i_res_n) begin
            r_cnt_flash <= 24'd0;
            r_flash_en <= 1'b0;
        end else begin
            if (w_cnt_max_flash) begin
                r_cnt_flash <= 24'd0;
                r_flash_en <= ~r_flash_en;
            end else begin
                r_cnt_flash <= r_cnt_flash + 24'd1;
            end
        end
    end

    assign o_tx_led_red =   (r_boot_st == 2'd0) ? 1'b1 :
                            (r_boot_st == 2'd1) ? 1'b0 :
                            (i_tx_err) ? r_flash_en :
                            1'b1;

    assign o_tx_led_gr =    (r_boot_st == 2'd0) ? 1'b1 :
                            (r_boot_st == 2'd1) ? 1'b0 :
                            i_tx_d1;

    assign o_rx_led_red =   (r_boot_st == 2'd0) ? 1'b1 :
                            (r_boot_st == 2'd1) ? 1'b0 :
                            (i_rx_err) ? r_flash_en :
                            1'b1;

    assign o_rx_led_gr =    (r_boot_st == 2'd0) ? 1'b1 :
                            (r_boot_st == 2'd1) ? 1'b0 :
                            i_rx_d1;
                     
endmodule
