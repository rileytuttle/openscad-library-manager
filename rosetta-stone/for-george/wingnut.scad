include <rosetta-stone/ball-mount-bits.scad>

// the resolution of the model. use lower resolution for faster compilation while testing
$fn=50; // [10:100]
// the type of screw to be used. defined here https://github.com/BelfrySCAD/BOSL2/wiki/screws.scad#subsection-screw-naming. ie metric "M6x1.0" us "1/4,20" or "5/16,18"
screw_profile="5/16,18";
// rough size of the wingnut [overall length, thickness must be wider than screw profile, overall height]
size = [40, 15, 20];

wingnut(screw_profile, size);
