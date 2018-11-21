XST_DIR=default_xst
DESIGN_NAME=slaveFIFO2b_fpga_top

fpga_master_bit:config Xst ngd map par trce bitstream mcs

fpga_master_bit_pre_inserter:config Xst

fpga_master_bit_post_inserter:ngd map par trce bitstream mcs

config: 
	@ -rm -rf ${XST_DIR} > /dev/null
	
	@echo -e "\n\nXILINX Working Directory Set to ${XST_DIR}\n"
	
	@ -mkdir ${XST_DIR} > /dev/null
	@cp  ${DESIGN_NAME}.ucf ${DESIGN_NAME}.xst ${DESIGN_NAME}.prj ${XST_DIR}/.  

Xst:
	@cd ${XST_DIR};  xst -ifn ${DESIGN_NAME}.xst ; cd -


chipscope:
	@cd ${XST_DIR}; inserter -create ${DESIGN_NAME}.cdc ; inserter -edit ${DESIGN_NAME}.cdc -p xc6slx16-3-csg324 ngcbuild -i ${DESIGN_NAME}.ngc ${DESIGN_NAME}_probes.ngc ; inserter -insert ${DESIGN_NAME}.cdc -p xc6slx16-3-csg324 ngcbuild -i ${DESIGN_NAME}.ngc ${DESIGN_NAME}_probes.ngc



ngd:
	@cd ${XST_DIR}; ngdbuild -uc ${DESIGN_NAME}.ucf ${DESIGN_NAME}; cd -

map:
	@cd ${XST_DIR}; map -xe n -detail -ol high -global_opt speed -pr b -w -p xc6slx16-3-csg324 -timing -c 100 -o ${DESIGN_NAME}.ncd ${DESIGN_NAME}.ngd ${DESIGN_NAME}.pcf ; cd -

par:
	@cd ${XST_DIR};	par -ol high -xe n ${DESIGN_NAME}.ncd -w ${DESIGN_NAME}.ncd ${DESIGN_NAME}.pcf ; cd -

trce:
	@cd ${XST_DIR}; trce -e 300 -l 300 -s 3 -xml ${DESIGN_NAME} ${DESIGN_NAME}.ncd -o ${DESIGN_NAME}.twr ${DESIGN_NAME}.pcf ; cd - 

bitstream:
	@cd ${XST_DIR}; bitgen "${DESIGN_NAME}.ncd" "${DESIGN_NAME}.bit" "${DESIGN_NAME}.pcf" -d -w -intstyle pa ; cd -

mcs:
	@cd ${XST_DIR};promgen -w -p mcs -c FF -o ${DESIGN_NAME} -u 00000000 ${DESIGN_NAME}.bit -s 65536
	
