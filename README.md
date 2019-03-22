# ULX3S-ADDA


https://github.com/albertxie/iverilog-tutorial

https://www.csee.umbc.edu/portal/help/VHDL/verilog/summary_one.html#specify

https://github.com/YosysHQ/nextpnr/blob/master/docs/constraints.md

http://www.latticesemi.com/-/media/LatticeSemi/Documents/ApplicationNotes/PT/sysIOUsageGuidelinesforLatticeDevices.ashx?document_id=3469

https://www.latticesemi.com/-/media/LatticeSemi/Documents/UserManuals/1D/design_planning_document.ashx?document_id=45589

	// 14ns after edge, data is stable (we'll use 16ns)
	specify 
		(J2_AD_PORT => i_ad_port_value) = 16;
	endspecify