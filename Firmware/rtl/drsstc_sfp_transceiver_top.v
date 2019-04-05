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
	input		[1:0] CLK_40M,
	input		[1:0] RST_N,
	
	/* 5V-TTL GPIO */
	input		[7:0]	IN,
	output	[7:0]	OUT,
	
	/* 3.3V-TTL GPIO */
	input		[2:0]	LV_IN,
	output	[2:0]	LV_OUT,
	
	/* Onboard DIP-SW */
	input		[7:0] DIP_SW1,
	input		[7:0] DIP_SW2,
	
	/* TX and RX LED */
	output	[1:0]	LED_TX,
	output	[1:0]	LED_RX,
	
	/* SFP Module */
	input		SFP_LOSS_SIG,	// If high, received optical power is below the worst-case receiver sensitivity. Low is normal operation.
	output	SFP_RATE_SEL,	// 
	output	SFP_TX_DIS_N,	// Tx disable. If high, transmitter disable.
	input		SFP_TX_FLT,		// If high, transmitter Fault. Low is normal operation.
	
	/* SFP MOD_DEF */
	inout		[2:0]	SFP_MOD_DEF,
	
	/* LVDS I/F IC */
	input		LVDS_DAT_OUT,	// Received Data in.
	output	LVDS_DAT_IN,	// Transmitter Data out.
	output	LVDS_DRV_EN,
	output	LVDS_RCV_EN_N,
	
	/* Debug */
	output	TP1,
	output	TP2
	);
	
	
	// TEST
	assign LED_TX[0] = !DIP_SW1[0];
	assign LED_TX[1] = !DIP_SW1[1];
	assign LED_RX[0] = !DIP_SW1[2];
	assign LED_RX[1] = !DIP_SW1[3];
	
	
	
	
endmodule