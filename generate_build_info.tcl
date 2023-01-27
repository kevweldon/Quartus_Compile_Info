# Kevin Weldon - Intel - 01/20/23

package require ::quartus::flow

global quartus

proc main {} {
    set SCRIPT_VERSION "1.0"
    set MIF_FILE "build_info.mif"
    set MEM_WIDTH 8
    set MEM_DEPTH 2048

    global quartus
    set device_info ""

    ################################################################
    # Add this scripts version to the device_info string
    set data "Script Version: $SCRIPT_VERSION"
    set device_info "${device_info}${data}\n"

    ################################################################
    # Add the date to the device_info string
    set data [clock format [clock seconds] -format {Build Date: %m/%d/%Y}]
    set device_info "${device_info}${data}\n"

    ################################################################
    # Add the time to the device_info string
    set data [clock format [clock seconds] -format {Build Time: %H:%M:%S}]
    set device_info "${device_info}${data}\n"
    
    ################################################################
    # Add the user name to the device_info string
    set data "User: $::tcl_platform(user)"
    set device_info "${device_info}${data}\n"
    
    ################################################################
    # Add the Quartus version to the device_info string
    set data "Quartus: $quartus(version)"
    set device_info "${device_info}${data}\n"

    ################################################################
    # Add the project name to the device_info string
    set proj_name [get_project_name]
    set data  "Project Name: $proj_name"
    set device_info "${device_info}${data}\n"

    ################################################################
    # Add the project revision to the device_info string
    set list_of_revisions [get_project_revisions $proj_name]
    set data "Revision Name: [lindex $list_of_revisions 0]"
    set device_info "${device_info}${data}\n"

    ################################################################
    # Add the OS to the device_info string
    # systeminfo | findstr /B /C:"OS Name" /B /C:"OS Version
    set data "OS: $::tcl_platform(os)"
    set device_info "${device_info}${data}\n"

    ################################################################
    # Add the OS version to the device_info string
    set data "OS Version: $::tcl_platform(osVersion)"
    set device_info "${device_info}${data}\n"

    ################################################################
    # Generate memory data array from the device_info string
    set memory [create_memory_data $device_info $MEM_DEPTH]

    ################################################################
    # Genearte MIF_FILE from the memory data array
    write_mif_file $memory $MIF_FILE $MEM_WIDTH $MEM_DEPTH
    
    ################################################################
    # Now we can update the project with our new MIF file
    if {![is_project_open]} {
        project_open "$proj_name" -current_revision
    }
    # Call the tool to add the updated MIF to the project
    execute_module -tool cdb -args "--update_mif"
    # Run the assembler
    execute_module -tool asm
    # Close the project
    project_close
}

proc write_mif_file {memory mif_file width depth} {
    if {[catch {set OUTPUT [open $mif_file w]}]} {
        post_message -type error "\nCould not create file $mif_file"
        return 0
    } else {
        post_message -type info "Creating memory initialization file $mif_file"
    }
    puts $OUTPUT "WIDTH=$width;\nDEPTH=$depth;\n"
    puts $OUTPUT "ADDRESS_RADIX=HEX;\nDATA_RADIX=HEX;\n"
    puts $OUTPUT "CONTENT BEGIN"
    for {set i 0} {$i < $depth} {incr i} {
        set address [format "%X" $i]
        set data [lindex $memory $i]
        if {!([regexp -- {\d+} $data])} {
            set data "00"
        }
        puts $OUTPUT "\t$address : $data;"
    }
    puts $OUTPUT "END;"
    close $OUTPUT
}

proc create_memory_data {string_val num_of_bytes} {
    # Split the data on white space
    set char_array [split $string_val ""]
    set string_length [llength $char_array]
    if {$string_length > $num_of_bytes} {
	puts "WARNING: String \"$string_val\" ($string_length bytes) is larger than $num_of_bytes bytes. \
	Will only store the first $num_of_bytes bytes."
	set char_array [lrange $char_array 0 [expr $num_of_bytes-1]]
    }
    for {set i 0} {$i < $num_of_bytes} {incr i} {
	if {$i < $string_length} {
	    set char [lindex $char_array $i]
	    set hex_ascii_char [format %02X [char2ASCII $char]]
	} else {
	    set hex_ascii_char "00"
	}
	lappend memory $hex_ascii_char
    }
    return $memory
}


################################################################
# This proc will return the name of the project in PWD
proc get_project_name {} {
    # Look for Quartus project files in the current directory
    set filelist [glob -nocomplain *.qpf]
    # Make sure there is at least one
    if {[llength $filelist] == 0} {
        post_message -type error "No project found in PWD to open"
        return 0
    }
    # Grab the first one you find
    set proj [lindex $filelist 0]
    # Remove the .qpf at the end of it
    regsub ".qpf$" $proj "" proj
    return $proj
}

################################################################
# This proc will left pad a digit to be the size
# of "pad_size" with the value of "pad_value".
proc pad_digit {val pad_value pad_size} {
    # Get the number of digits in the value
    set num_of_digits [llength [split $val ""]]
    set ans ""
    for {set i $num_of_digits} {$i < $pad_size} {incr i} {
        set ans "${pad_value}${ans}"
    }
    set ans "${ans}${val}"
    return $ans
}

################################################################
# This proc will convert a char to an ASCII value
proc char2ASCII { char } {
    scan $char %c value
    return $value
}

################################################################
# This proc will convert a string to an array of hex values.
proc str2hex { string } {
    set chars [split $string ""]
    # Convert each char to an ASCII value
    foreach char $chars {
        set ascii_char [format %X [char2ASCII $char]]
        # Pad the hex ASCII value to two bits
        lappend hex_str [pad_digit ${ascii_char} "0" "2"]
    }
    puts "$hex_str"
    return $hex_str
}

main
return 1
