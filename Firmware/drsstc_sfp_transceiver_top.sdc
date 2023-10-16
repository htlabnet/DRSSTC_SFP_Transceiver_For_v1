## Generated SDC file "drsstc_sfp_transceiver_top.sdc"

## Copyright (C) 2018  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 18.1.0 Build 625 09/12/2018 SJ Lite Edition"

## DATE    "Mon Nov 23 23:11:11 2020"

##
## DEVICE  "EPM570T100C5"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {CLK_60M} -period 16.666 -waveform { 0.000 8.333 } [get_ports {CLK_60M[0]}]


#**************************************************************
# Create Generated Clock
#**************************************************************



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************



#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************

set_false_path -from [get_ports {RST_N[*]}]

set_false_path -from [get_ports {IN[*]}]
set_false_path -to   [get_ports {OUT[*]}]

set_false_path -from [get_ports {LV_IN[*]}]
set_false_path -to   [get_ports {LV_OUT[*]}]

set_false_path -from [get_ports {DIP_SW1[*]}]
set_false_path -from [get_ports {DIP_SW2[*]}]

set_false_path -to   [get_ports {LED_TX[*]}]
set_false_path -to   [get_ports {LED_RX[*]}]

set_false_path -from [get_ports {SFP_LOSS_SIG}]
set_false_path -to   [get_ports {SFP_RATE_SEL}]
set_false_path -to   [get_ports {SFP_TX_DIS_N}]
set_false_path -from [get_ports {SFP_TX_FLT}]
set_false_path -from [get_ports {SFP_MOD_DEF[*]}]
set_false_path -to   [get_ports {SFP_MOD_DEF[*]}]

set_false_path -from [get_ports {LVDS_DAT_OUT}]
set_false_path -to   [get_ports {LVDS_DAT_IN}]
set_false_path -to   [get_ports {LVDS_DRV_EN}]
set_false_path -to   [get_ports {LVDS_RCV_EN_N}]

set_false_path -to   [get_ports {TP1}]
set_false_path -to   [get_ports {TP2}]


#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

