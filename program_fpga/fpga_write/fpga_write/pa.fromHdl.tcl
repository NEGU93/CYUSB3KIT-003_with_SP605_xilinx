
# PlanAhead Launch Script for Pre-Synthesis Floorplanning, created by Project Navigator

create_project -name fpga_write -dir "C:/Documents and Settings/shya/Desktop/cy project/new hrid fx3 fpga project/for SP6/100 MHz/last mint in 100 mhz/all signlas added/zlp and partial flag 32 bit in watermark 4/fpga_write/planAhead_run_1" -part xc6slx16csg324-3
set_param project.pinAheadLayout yes
set srcset [get_property srcset [current_run -impl]]
set_property target_constrs_file "fpga_master.ucf" [current_fileset -constrset]
set hdlfile [add_files [list {ipcore_dir/clk_wiz_v3_6.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {test.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set_property top fpga_master $srcset
add_files [list {fpga_master.ucf}] -fileset [get_property constrset [current_run]]
open_rtl_design -part xc6slx16csg324-3
