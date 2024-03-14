# get the frames in the movie
display depthcue off
set frm [molinfo top get frame]
set filename snap.[format "%04d" $frm].pov
render POV3 $filename  povray +W2500 +H2500 -I%s -O%s.tga +X +A +FT +UA
puts "redering finished"