set QUARTUS_PROJECT_NAME=top

@echo off
echo ####################
echo ## Compiling FPGA ##
echo ####################
quartus_sh --flow compile %QUARTUS_PROJECT_NAME%
