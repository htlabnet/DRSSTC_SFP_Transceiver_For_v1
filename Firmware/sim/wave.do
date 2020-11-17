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

# hoge
