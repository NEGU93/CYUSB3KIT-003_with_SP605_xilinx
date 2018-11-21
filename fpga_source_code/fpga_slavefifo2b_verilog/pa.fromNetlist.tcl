
# PlanAhead Launch Script for Post-Synthesis floorplanning, created by Project Navigator

create_project -name slavefifo2b_verilog_feb20 -dir "C:/unzipped/fpga_slavefifo2b_verilog/fpga_slavefifo2b_verilog/planAhead_run_2" -part xc6slx16csg324-3
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "C:/unzipped/fpga_slavefifo2b_verilog/fpga_slavefifo2b_verilog/slaveFIFO2b_fpga_top.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {C:/unzipped/fpga_slavefifo2b_verilog/fpga_slavefifo2b_verilog} }
set_property target_constrs_file "slaveFIFO2b_fpga_top.ucf" [current_fileset -constrset]
add_files [list {slaveFIFO2b_fpga_top.ucf}] -fileset [get_property constrset [current_run]]
link_design
