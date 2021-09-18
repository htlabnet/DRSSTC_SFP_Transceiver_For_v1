/*============================================================================*/
/*
 * @file    drsstc_sfp_transceiver_top.v
 * @brief   drsstc_sfp_transceiver top module
 * @note    http://htlab.net/
 * @date    2019/04/05
 * @author  pcjpnet
 */
/*============================================================================*/

module drsstc_sfp_transceiver_top (
    /* Master Clock and Reset */
    input   [1:0]   CLK_40M,
    input   [1:0]   RST_N,
    
    /* 5V-TTL GPIO */
    input   [7:0]   IN,
    output  [7:0]   OUT,
    
    /* 3.3V-TTL GPIO */
    input   [2:0]   LV_IN,
    output  [2:0]   LV_OUT,
    
    /* Onboard DIP-SW */
    input   [7:0]   DIP_SW1,
    input   [7:0]   DIP_SW2,
    
    /* TX and RX LED */
    output  [1:0]   LED_TX,
    output  [1:0]   LED_RX,
    
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
    wire            w_IsMaster = ~DIP_SW1[0];
    wire    [2:0]   w_option = ~DIP_SW1[3:1];
    wire            w_clk = CLK_40M[0];
    wire    [1:0]   w_tx_led;
    wire    [1:0]   w_rx_led;
    
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
    // Boot (reset) sequence
    //==================================================================
    boot_seq boot_seq_inst (
        .i_clk ( w_clk ),
        .i_res_n ( w_rst_n ),

        .i_rx_led ( w_rx_led[1:0] ),
        .i_tx_led ( w_tx_led[1:0] ),
        .o_rx_led ( LED_RX[1:0] ),
        .o_tx_led ( LED_TX[1:0] )
    );

    //==================================================================
    // Serial data Transmitter
    //==================================================================
    serial_tx_master serial_tx_master_inst (
        .i_clk ( w_clk ),
        .i_res_n ( w_rst_n ),

        .i_sfp_tx_flt ( SFP_TX_FLT ),
        .i_IsPro ( 1'b0 ),
        .i_IsMaster ( w_IsMaster ),
        .i_RawPls ( IN[0] ),            // Debug
        .i_Option ( {2'd0, IN[1]} ),    // Debug

        .o_SerialData ( LVDS_DAT_IN ),
        .o_drv_en ( LVDS_DRV_EN ),
        .o_sfp_tx_dis_n ( SFP_TX_DIS_N ),
        .o_tx_led ( w_tx_led[1:0] )
    );

    //==================================================================
    // Serial data receiver
    //==================================================================
    wire    [2:0]   w_rx_option;
    serial_rx serial_rx_inst (
        .i_clk ( w_clk ),
        .i_res_n ( w_rst_n ),

        .i_SerialData ( LVDS_DAT_OUT ),
        .i_sfp_los ( SFP_LOSS_SIG ),
        
        .o_rcv_en_n ( LVDS_RCV_EN_N ),
        .o_IsPro (  ),
        .o_IsMaster (  ),
        .o_RawPls ( OUT[0] ),
        .o_Option ( w_rx_option[2:0] ),
        .o_rx_led ( w_rx_led[1:0] )
    );

    assign OUT[1] = w_rx_option[0];  // Debug

    // TODO
    assign OUT[7:2] = 6'd0;
    assign LV_OUT[2:0] = 3'd0;
    assign TP1 = 1'b0;
    assign TP2 = 1'b0;
    assign SFP_RATE_SEL = 1'b0;
    assign SFP_MOD_DEF = 3'bzzz;
    
endmodule
