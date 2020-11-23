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
add wave -group top_tb /tb_top/res_n
add wave -group top_tb /tb_top/r_5v_ttl
add wave -group top_tb /tb_top/w_5v_ttl
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

# SerialTx_Master.v
add wave -group tx_data_gen /tb_top/dut/SerialTx_Master_inst/o_SerialData
add wave -group tx_data_gen /tb_top/dut/SerialTx_Master_inst/w_dispout
add wave -group tx_data_gen /tb_top/dut/SerialTx_Master_inst/r_dispin
add wave -group tx_data_gen /tb_top/dut/SerialTx_Master_inst/r_mosi_8b
add wave -group tx_data_gen /tb_top/dut/SerialTx_Master_inst/w_data_10b
add wave -group tx_data_gen /tb_top/dut/SerialTx_Master_inst/r_ser_prsc
add wave -group tx_data_gen /tb_top/dut/SerialTx_Master_inst/w_sample_prsc_en
add wave -group tx_data_gen /tb_top/dut/SerialTx_Master_inst/r_sample_prsc_en_ff
add wave -group tx_data_gen /tb_top/dut/SerialTx_Master_inst/r_tx_shiftreg

