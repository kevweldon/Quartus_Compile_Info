@echo off

echo Programming FPGA...
quartus_stp_tcl -t program_fpga.tcl

echo Resetting the design...
quartus_stp -t toggle_issp.tcl
