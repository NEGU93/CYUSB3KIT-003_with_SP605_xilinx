
# PlanAhead Launch Script for Post-Synthesis floorplanning, created by Project Navigator

create_project -name slavefifo2b_vhdl_feb20 -dir "/home/ise/AN65974/fx3_slavefifo2b_vhdl_proj/planAhead_run_1" -part xc6slx45tfgg484-3
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "/home/ise/AN65974/fx3_slavefifo2b_vhdl_proj/slaveFIFO2b_fpga_top.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {/home/ise/AN65974/fx3_slavefifo2b_vhdl_proj} }
set_property target_constrs_file "/home/ise/AN65974/slaveFIFO2b_fpga_top.ucf" [current_fileset -constrset]
add_files [list {/home/ise/AN65974/slaveFIFO2b_fpga_top.ucf}] -fileset [get_property constrset [current_run]]
link_design
