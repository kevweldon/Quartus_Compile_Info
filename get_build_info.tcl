
proc main {} {

    set MEM_DEPTH 2048
    set BUILD_INFO_RAM_ADDRESS 0

    #########################
    # Open the service path #
    #########################
    set jm [get_jtag_master];
    puts "Opening master: $jm\n"
    open_service master $jm

    ############################
    # Read the device info RAM #
    ############################
    set device_info [mem_read $jm $BUILD_INFO_RAM_ADDRESS $MEM_DEPTH]
    puts "$device_info"

    #########################
    # Close the JTAG master #
    #########################
    close_service master $jm
    return 0;
}

##########################################################
# This proc will read a block of memory that is a string
proc mem_read {jm address mem_size} {
    set device_info ""
    set read_value [master_read_8 $jm 0 $mem_size]
    foreach ascii_hex $read_value {
	scan $ascii_hex %x ascii_char
        if {$ascii_char != "00"} {
            regsub -all {^(0)+} $ascii_char {} ascii_char
	    # Convert ASCII to a char and apppend to device_info string
            set device_info "${device_info}[format %c $ascii_char]"
        }
    }
    return $device_info
}

proc get_jtag_master {} {
    #########################
    # Open the service path #
    #########################
    # You may need to adjust the value of the MASTER_INDEX
    set MASTER_INDEX 0
    puts "Opening JTAG master service path..."
    set i 0
    # Print all the masters found in the system. Here we need
    # to select the jtag2avalon master
    puts "I found the following masters:"
    foreach master [get_service_paths master] {
	puts "$i. $master"
	incr i
    }
    set jm [ lindex [ get_service_paths master ] $MASTER_INDEX ]
    return $jm
}


main

