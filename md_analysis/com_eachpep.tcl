
#pbc wrap -center com -centersel "protein" -compound chain -all 


################################### radius of gyration################
proc gyr_radius {sel} {
  # make sure this is a proper selection and has atoms
  if {[$sel num] <= 0} {
    error "gyr_radius: must have at least one atom in selection"
  }
  # gyration is sqrt( sum((r(i) - r(center_of_mass))^2) / N)
  set com [center_of_mass $sel]
  #puts $com
  set sum 0
  foreach coord [$sel get {x y z}] {
    set sum [vecadd $sum [veclength2 [vecsub $coord $com]]]
  }
  return [ expr sqrt($sum / ([$sel num] + 0.0))]
}


#################### center of mass##################
proc center_of_mass {selection} {
        # some error checking
        if {[$selection num] <= 0} {
                error "center_of_mass: needs a selection with atoms"
        }
        # set the center of mass to 0
        set com [veczero]
        # set the total mass to 0
        set mass 0
        # [$selection get {x y z}] returns the coordinates {x y z} 
        # [$selection get {mass}] returns the masses
        # so the following says "for each pair of {coordinates} and masses,
	#  do the computation ..."
        foreach coord [$selection get {x y z}] m [$selection get mass] {
           # sum of the masses
           set mass [expr $mass + $m]
           # sum up the product of mass and coordinate
           set com [vecadd $com [vecscale $m $coord]]
        }
        # and scale by the inverse of the number of atoms
        if {$mass == 0} {
                error "center_of_mass: total mass is zero"
        }
        # The "1.0" can't be "1", since otherwise integer division is done
        return [vecscale [expr 1.0/$mass] $com]
}


############################ code#########################
set outfile [open com_eachpep.dat w]
#puts $outfile "i rad_of_gyr"
set nf [molinfo top get numframes] 
set segsel [atomselect top "protein"]
set segnamelist [lsort -unique [$segsel get segname]]


for {set i 0} {$i < $nf} {incr i} {
    puts $outfile "######frame=$i######"
    set percent [format "%.1f" [expr (($i+1)*100)/$nf]]
    puts " $percent % "
    foreach x $segnamelist {
    set prot [atomselect top "segname $x"]
    $prot frame $i
    $prot update

    set com [center_of_mass $prot]
       
    puts $outfile "$x $com"
    }
    
}
	

close $outfile
