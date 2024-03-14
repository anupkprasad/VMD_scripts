#!/usr/bin/tclsh
# Anup K. Prasad
# anupkprasad121@gmail.com
# Ph.D @IITB-Monash Research Academy
# @2022, VMD script for gif

proc make_rotation_animated_gif {} {
	set frame 0
	for {set i 0} {$i < 360} {incr i 3} {
		set filename snap.[format "%04d" $frame].pov
		render POV3 $filename  povray +W2000 +H2000 -I%s -O%s.tga +X +A +FT +UA
		incr frame
		rotate y by 3
	}
	exec convert -delay 10 -loop 4 snap.*.rgb movie.gif
	rm snap.*.rgb
}



###previous
#proc make_rotation_animated_gif {} {
	#set frame 0
	#for {set i 0} {$i < 360} {incr i 20} {
		#set filename snap.[format "%04d" $frame].rgb
		#render snapshot $filename
		#incr frame
		#rotate y by 20
	#}
	#exec convert -delay 10 -loop 4 snap.*.rgb movie.gif
	#rm snap.*.rgb
#}
