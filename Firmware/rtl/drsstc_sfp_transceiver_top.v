/*============================================================================*/
/*
 * @file    drsstc_sfp_transceiver_top.v
 * @brief   drsstc_sfp_transceiver top module
 * @note    http://htlab.net/
 * @date    2023/10/16
 * @author  pcjpnet
 */
/*============================================================================*/

module drsstc_sfp_transceiver_top (
    /* Master Clock and Reset */
    input   [1:0]   CLK_60M,
    input   [1:0]   RST_N,
    
    /* 5V-TTL GPIO */
    input   [7:0]   IN,
    output  [7:0]   OUT,
    
    /* 3.3V-TTL GPIO */
    input   [2:0]   LV_IN,
    output  [2:0]   LV_OUT,
    
    /* Onboard DIP-SW */
    input   [7:0]   DIP_SW1,        // Low-active (ON:Low, OFF:High)
    input   [7:0]   DIP_SW2,        // Low-active (ON:Low, OFF:High)
    
    /* TX and RX LED */
    output  [1:0]   LED_TX,         // [1]:RED, [0];GR
    output  [1:0]   LED_RX,         // [1]:RED, [0];GR
    
    /* SFP Module */
    input           SFP_LOSS_SIG,   // If high, received optical power is below the worst-case receiver sensitivity. Low is normal operation.
    output          SFP_RATE_SEL,   // Low:Reduced Bandwidth / High:Full Bandwidth
    output          SFP_TX_DIS_N,   // Tx disable. If high, transmitter disable.
    input           SFP_TX_FLT,     // If high, transmitter Fault. Low is normal operation.
    
    /* SFP MOD_DEF */
    inout   [2:0]   SFP_MOD_DEF,    // Two wire serial interface for serial ID.
    
    /* LVDS I/F IC */
    input           LVDS_DAT_OUT,   // Received Data in.
    output          LVDS_DAT_IN,    // Transmitter Data out.
    output          LVDS_DRV_EN,    // Driver Enable
    output          LVDS_RCV_EN_N,  // Receiver Enable(Active Low)
    
    /* Debug */
    output          TP1,
    output          TP2
    );

    //==================================================================
    // wire
    //==================================================================
    wire            w_clk = CLK_60M[0];
    wire            w_my_locked;        // 自機のロック状態
    wire            w_rx_locked;        // 受信フレーム内のロックステータス
    
    //==================================================================
    // Reset
    //==================================================================
    wire            w_rst_n;
    reset_gen reset_gen_inst (
        .i_clk ( w_clk ),
        .i_res_n ( RST_N[0] ),
        .o_res_n ( w_rst_n )
    );

    //==================================================================
    // Status LED control
    //==================================================================
    led_ctrl led_ctrl_inst (
        .i_clk ( w_clk ),
        .i_res_n ( w_rst_n ),
        .i_tx_d1 ( IN[0] ),
        .i_tx_err ( SFP_MOD_DEF[0] | SFP_TX_FLT ),
        .i_rx_d1 ( OUT[0] ),
        .i_rx_err ( SFP_MOD_DEF[0] | SFP_LOSS_SIG | ~w_my_locked),
        .o_tx_led_red ( LED_TX[1] ),
        .o_tx_led_gr ( LED_TX[0] ),
        .o_rx_led_red ( LED_RX[1] ),
        .o_rx_led_gr ( LED_RX[0] )
    );

    //==================================================================
    // Serial data Transmitter
    //==================================================================
    serial_tx_master serial_tx_master_inst (
        .i_clk ( w_clk ),
        .i_res_n ( w_rst_n ),
        .i_sfp_tx_flt ( SFP_TX_FLT ),
        .i_my_lock ( w_my_locked ),         // 自機のロック状態
        .i_rx_lock ( w_rx_locked ),         // 受信フレームのロック状態
        .i_data ( IN[3:0] ),
        .i_master ( ~DIP_SW2[0] ),
        .o_SerialData ( LVDS_DAT_IN ),
        .o_drv_en ( LVDS_DRV_EN ),
        .o_sfp_tx_dis_n ( SFP_TX_DIS_N )
    );


    //==================================================================
    // Serial data receiver
    //==================================================================
    wire    [3:0]   w_rx_data;
    wire            w_rx_master;
    serial_rx serial_rx_inst (
        .i_clk ( w_clk ),
        .i_res_n ( w_rst_n ),
        .i_SerialData ( LVDS_DAT_OUT ),
        .i_sfp_los ( SFP_LOSS_SIG ),
        .o_rcv_en_n ( LVDS_RCV_EN_N ),
        .i_dip_sel ( DIP_SW1[3:0] ),
        .o_my_lock ( w_my_locked ),     // 自機の8b10bシンボルロック状態
        .o_rx_lock ( w_rx_locked ),     // フレームに内包されていたLockビット状態
        .o_data ( w_rx_data[3:0] ),
        .o_master ( w_rx_master )
    );

    assign OUT[3:0] = w_rx_data[3:0];
    assign OUT[4] = w_my_locked;
    assign OUT[5] = w_rx_locked;
    assign OUT[6] = w_rx_master;
    assign LV_OUT[2:0] = w_rx_data[2:0];

    // Reserved
    assign OUT[7] = 2'd0;
    assign TP1 = 1'b0;
    assign TP2 = 1'b0;
    assign SFP_RATE_SEL = 1'b0;
    assign SFP_MOD_DEF = 3'bzzz;
    
endmodule
