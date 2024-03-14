# get the secondary structure of protein CA atoms, each line represent frame

set sel [atomselect top "name CA"]
set n [molinfo top get numframes]
set outfile [open ss_traj.dat w]

for { set i 0 } { $i < $n } { incr i } {
 animate goto $i
 display update off
 $sel frame $i
 mol ssrecalc top
 set secstruct [$sel get structure]
 puts $outfile "$secstruct"
}

display update on
close $outfile