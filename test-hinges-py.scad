include <rosetta-stone/hinges.scad>

translate([0, 0, 0]) rotate([0, 0, 0]) union() {

translate([0, 0, 0]) rotate([0, 0, 0]) hinge_fin(
angle_per_fin=20,
cut_depth=30,
height_of_cut=5,
top_length_of_fin=5,
minimum_gap=0.4,
fudge_factor=0.001,
spin=0,
orient=[0, 0, 1],
anchor=[0, 0, 0]);

translate([0, -10, 0]) rotate([0, 0, 30]) hinge_fin(
angle_per_fin=20,
cut_depth=30,
height_of_cut=5,
top_length_of_fin=5,
minimum_gap=0.4,
fudge_factor=0.001,
spin=0,
orient=[0, 0, 1],
anchor=[0, 0, 0]);

}