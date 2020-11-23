#=============================================================================
#
# @file     sim.do
# @brief    ModelSim script file
# @note     
# @date     2020/11/18
# @author   kingyo
#
#=============================================================================

vlib work
vmap work work

vlog \
    -L work \
    -l vlog.log \
    -work work \
    -timescale "1ns / 100ps" \
    -f filelist.txt 

vsim tb_top -wlf vsim.wlf -wlfcachesize 512

do wave.do
run 1ms
WaveRestoreZoom {0 ns} {1 ms}
