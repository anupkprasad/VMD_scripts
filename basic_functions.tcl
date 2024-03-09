#!/usr/bin/tclsh
#### Basic functions to apply on trajectory/frame in VMD @2022
# Anup K. Prasad
# anupkprasad121@gmail.com
# Ph.D @IITB-Monash Research Academy

proc traj_load {{datapath} {step 10} {wrap "No"} {sscache "NO"}} {
	set tclscriptpath /media/anupkumar/Backup\ Plus/scripts/tcl
	set psf_name [lindex [glob -directory $datapath *.psf] {0}]
	puts $psf_name
	mol new $psf_name
	set prod_list [glob -directory $datapath -type d *{prod,Prod}*]
	## sorting the prod_list according ASCII
	set prod_list [lsort -dictionary $prod_list]
	foreach prod $prod_list {
		puts $prod
		set filename [lindex [glob -directory $prod/ *.dcd] {0}]
		puts $filename
		mol addfile $filename first 0 last -1 step $step waitfor all
	}
	if {$wrap != "No"} {
		pbc wrap -center com -centersel "protein" -compound fragment -all
	}
	if {$sscache != "No"} {
		source $tclscriptpath/sscache.tcl
	}
	puts "Trajectory is loaded"
}


proc traj_writepdb {{molid top} {sel "protein"}} {
	## write pdb for trajectory
	set sel [atomselect $molid $sel]
	set n [molinfo $molid get numframes]
	for { set i 0 } { $i < $n } { incr i } {
		$sel frame $i
		$sel writepdb $i.pdb
	}
}



proc get_aminoseq {{molid top}} {
	set aa_triple { ALA CYS ASP GLU PHE GLY HIS ILE LYS LEU MET ASN PRO GLN ARG SER THR VAL TRP TYR}
	set aa_single { A C D E F G H I K L M N P Q R S T V W Y }
	set sel [atomselect $molid "protein"]
	set uresid [lsort -unique [$sel get resid]]
	## sorting the prod_list according ASCII
	set uresid [lsort -dictionary $uresid]
	set amino_acids ""
	foreach rid $uresid {
		set sel_rid [atomselect $molid "resid $rid"]
	    set rsnm [lsort -unique [$sel_rid get resname]]
	    puts $rsnm
	    set aa_in [lsearch -exact $aa_triple $rsnm]
	    append amino_acids [lindex $aa_single $aa_in]
	    $sel_rid delete
	}
	set cter [atomselect $molid "resid [lindex $uresid end]"]
	set cter_atms [$cter get name]
	if {[lsearch -exact $cter_atms "NT"] >= 0} {
    append amino_acids "-NH2"
	}
	puts "Amino Acid Sequence: $amino_acids"
	$sel delete
	return $amino_acids
}



proc assign_uniqueid {pdbfile} {
	mol new $pdbfile.pdb
	pbc set {0 0 0} 
	set proteins [atomselect top "protein"]
	set outfile [open ${pdbfile}_u.pdb w+]
	## pfrag does not work if protein fragments clash and mistacally gives -ve value
	set chains [lsort -unique [$proteins get pfrag]]
	foreach chain $chains {
		set sel [atomselect top "pfrag $chain"];
		$sel set segname P$chain
		$sel writepdb frag_temp.pdb
		set temp_data [split [read [open frag_temp.pdb]] "\n"]
		if {[lindex $temp_data 0 0] == "CRYST1"} {
			puts "Box info removed from pdb of pfrag $chain"
			puts $outfile [join [lrange $temp_data 1 end-1] "\n"]
		} else {
			puts "No box info in given pdb"
			puts $outfile [join [lrange $temp_data 0 end-1] "\n"]
		}
	}
	close $outfile
	mol delete top
	assign_ENDtoTER_pdb ${pdbfile}_u
}


proc assign_ENDtoTER_pdb {filename} {
    mol new $filename.pdb
    set myfile [open ${filename}.pdb]
    set lines [split [read $myfile] "\n"]
    close $myfile;
    set outfile [open ${filename}.pdb w+]
    foreach line [lrange $lines 0 end-2] {
        # do something with each line...
        if {$line == "END"} {
            puts $outfile "TER"
        } else {
            puts $outfile $line
        }
	}
    puts $outfile [lindex $lines end-1]
    close $outfile
    mol delete top
}