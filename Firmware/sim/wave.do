#=============================================================================
#
# @file     wave.do
# @brief    Wave script file
# @note     
# @date     2020/11/18
# @author   kingyo
#
#=============================================================================

configure wave -namecolwidth 300

# TOP
add wave -group top_tb /tb_top/mco
add wave -group top_tb /tb_top/jclk
add wave -group top_tb /tb_top/res_n
add wave -group top_tb /tb_top/w_5v_ttl_in
add wave -group top_tb /tb_top/w_5v_ttl_out
add wave -group top_tb /tb_top/r_3v3_ttl
add wave -group top_tb /tb_top/w_3v3_ttl
add wave -group top_tb /tb_top/r_dip_sw1
add wave -group top_tb /tb_top/r_dip_sw2
add wave -group top_tb /tb_top/w_led_tx
add wave -group top_tb /tb_top/w_led_rx
add wave -group top_tb /tb_top/r_sfp_loss_sig
add wave -group top_tb /tb_top/w_sfp_rate_sel
add wave -group top_tb /tb_top/w_sfp_tx_dis_n
add wave -group top_tb /tb_top/r_sfp_tx_flt
add wave -group top_tb /tb_top/w_sfp_mod_def
add wave -group top_tb /tb_top/r_lvds_dat_out
add wave -group top_tb /tb_top/w_lvds_dat_in
add wave -group top_tb /tb_top/w_lvds_drv_en
add wave -group top_tb /tb_top/w_lvds_rcv_en_n
add wave -group top_tb /tb_top/w_tp1
add wave -group top_tb /tb_top/w_tp2

# serial_tx_master.v
add wave -group serial_tx_master /tb_top/dut/serial_tx_master_inst/i_clk
add wave -group serial_tx_master /tb_top/dut/serial_tx_master_inst/w_ser_en
add wave -group serial_tx_master /tb_top/dut/serial_tx_master_inst/o_SerialData
add wave -group serial_tx_master /tb_top/dut/serial_tx_master_inst/w_k28_5_en
add wave -group serial_tx_master /tb_top/dut/serial_tx_master_inst/w_dispout
add wave -group serial_tx_master /tb_top/dut/serial_tx_master_inst/r_dispin
add wave -group serial_tx_master /tb_top/dut/serial_tx_master_inst/r_mosi_8b
add wave -group serial_tx_master /tb_top/dut/serial_tx_master_inst/w_data_10b
add wave -group serial_tx_master /tb_top/dut/serial_tx_master_inst/r_ser_prsc
add wave -group serial_tx_master /tb_top/dut/serial_tx_master_inst/w_sample_prsc_en
add wave -group serial_tx_master /tb_top/dut/serial_tx_master_inst/r_sample_prsc_en_ff
add wave -group serial_tx_master /tb_top/dut/serial_tx_master_inst/r_tx_shiftreg

# cdr.v
add wave -group cdr /tb_top/dut/serial_rx_inst/cdr_inst/r_syncFF
add wave -group cdr /tb_top/dut/serial_rx_inst/cdr_inst/w_ts
add wave -group cdr /tb_top/dut/serial_rx_inst/cdr_inst/r_rcvState
add wave -group cdr /tb_top/dut/serial_rx_inst/cdr_inst/o_RecoveryData
add wave -group cdr /tb_top/dut/serial_rx_inst/cdr_inst/o_DataEn

# serial_rx.v
add wave -group serial_rx /tb_top/dut/serial_rx_inst/w_k28_5_det
add wave -group serial_rx /tb_top/dut/serial_rx_inst/r_sym_locked
add wave -group serial_rx /tb_top/dut/serial_rx_inst/r_sym_bitCnt
add wave -group serial_rx /tb_top/dut/serial_rx_inst/r_sym_data
add wave -group serial_rx /tb_top/dut/serial_rx_inst/r_sym_capture
add wave -group serial_rx /tb_top/dut/serial_rx_inst/w_8b_data
add wave -group serial_rx /tb_top/dut/serial_rx_inst/r_disp
add wave -group serial_rx /tb_top/dut/serial_rx_inst/r_code_err
add wave -group serial_rx /tb_top/dut/serial_rx_inst/r_disp_err
add wave -group serial_rx /tb_top/dut/serial_rx_inst/o_IsPro
add wave -group serial_rx /tb_top/dut/serial_rx_inst/o_IsMaster
add wave -group serial_rx /tb_top/dut/serial_rx_inst/o_RawPls
add wave -group serial_rx /tb_top/dut/serial_rx_inst/o_Option

