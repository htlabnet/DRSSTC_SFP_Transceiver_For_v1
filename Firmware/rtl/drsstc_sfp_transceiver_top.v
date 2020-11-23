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
    
    //==================================================================
    // Reset
    //==================================================================
    wire            w_rst_n;
    rstGen rstGen_inst (
        .i_clk ( CLK_40M[0] ),
        .i_res_n ( RST_N[0] ),
        .o_res_n ( w_rst_n )
    );


    //==================================================================
    // *** Interrupter signal for Debug Only
    // *** Freq = 1kHz, Duty = 50%
    //==================================================================
    reg     [23:0]  r_dbg_sig_cnt;
    reg             r_dbg_pls;
    wire            w_dbg_sig_clr = (r_dbg_sig_cnt == 24'd19999);
    always @(posedge CLK_40M[0] or negedge w_rst_n) begin
        if (~w_rst_n) begin
            r_dbg_sig_cnt <= 24'd0;
            r_dbg_pls <= 1'b0;
        end else if (w_dbg_sig_clr) begin
            r_dbg_sig_cnt <= 24'd0;
            r_dbg_pls <= ~r_dbg_pls;
        end else begin
            r_dbg_sig_cnt <= r_dbg_sig_cnt + 24'd1;
        end
    end


    //==================================================================
    // Serial data Transmitter
    //==================================================================
    SerialTx_Master SerialTx_Master_inst (
        .i_clk ( CLK_40M[0] ),
        .i_res_n ( w_rst_n ),

        .i_sfp_tx_flt ( SFP_TX_FLT ),
        .i_IsPro ( 1'b0 ),
        .i_IsMaster ( w_IsMaster ),
        //.i_RawPls ( IN[0] ),
        .i_RawPls ( r_dbg_pls ),    // Debug
        .i_Option ( 3'b111 ),       // Debug

        .o_SerialData ( LVDS_DAT_IN ),
        .o_drv_en ( LVDS_DRV_EN ),
        .o_sfp_tx_dis_n ( SFP_TX_DIS_N ),
        .o_tx_led ( LED_TX[1:0] )
    );


    assign SFP_RATE_SEL = 1'b0;
    assign SFP_MOD_DEF = 3'bzzz;
    
endmodule
