
# PlanAhead Launch Script for Post-Synthesis floorplanning, created by Project Navigator

create_project -name tutorial -dir "/home/barrachina/Documents/MIMAC/CYUSB3KIT-003_with_SP605_xilinx/fpga_source_code/tutorial/planAhead_run_2" -part xc6slx45tfgg484-3
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "/home/barrachina/Documents/MIMAC/CYUSB3KIT-003_with_SP605_xilinx/fpga_source_code/tutorial/counter.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {/home/barrachina/Documents/MIMAC/CYUSB3KIT-003_with_SP605_xilinx/fpga_source_code/tutorial} }
set_property target_constrs_file "counter.ucf" [current_fileset -constrset]
add_files [list {counter.ucf}] -fileset [get_property constrset [current_run]]
link_design
