#!/usr/bin/tclsh
#### Get transformation matrix @2023
# Anup K. Prasad
# anupkprasad121@gmail.com
# Ph.D @IITB-Monash Research Academy

proc transmatrix {filename} {
    set fp [open $filename r]
    set matrix {}
    set count 1
    while {[gets $fp line]!=-1} {
        incr count
        if {$count==28} {
            set a $line
            lappend matrix $line
            }
        if {$count==29} {
            set b $line
            lappend matrix $line
            }
        if {$count==30} {
            set c $line
            lappend matrix $line
            }
        if {$count==31} {
            set d $line
            lappend matrix $line
                break
            }
    }
    close $fp
    puts "Transformation matrix retrieved"
    return $matrix
}

proc get_propgatedpdb {pdbfile {num 7}} {
    mol new ${pdbfile}.pdb
    set matrix [transmatrix "${pdbfile}_matrix.hex"]
    set sel [atomselect top all]
    set n $num
    for {set i 1} {$i <= $n} {incr i} {
        animate dup frame [expr {$i-1}] [molinfo top get id] 
        $sel frame $i
        $sel move $matrix
    }
    animate write pdb ${pdbfile}_docked.pdb
    $sel delete
    assign_ENDtoTER_pdb ${pdbfile}_docked
    mol delete all
    mol new ${pdbfile}_docked.pdb
}

proc load_dockedfiles { } {
    set docked_pdbs [glob -directory ./ *docked.pdb]
    foreach pdb $docked_pdbs {
        puts $pdb
        mol new $pdb
        set clash_atoms [measure contacts 1.5 [atomselect top all]]
        set atom_num [llength [lindex $clash_atoms 0]]
        if {$atom_num != 0} {
            mol delete top
            puts "filename: $pdb \n Clashed atoms = $atom_num"
        }
    }
}
