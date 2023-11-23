include <BOSL2/std.scad>
include <rosetta-stone/sheet-metal.scad>


translate([0, 0, 0]) rotate([0, 0, 0]) cube(
size=[100, 100, 5],
spin=0,
orient=[0, 0, 1],
anchor=[0, 0, 0])
    attach([1, 0, 0], "attach1")
    sheetmetal_bend(
        metal_thickness=5,
        ir=10,
        ang=90,
        edge_len=100,
        bend=true,
        spin=-90,
        orient=[6.123233995736766e-17, 0, 1.0],
        anchor="attach1");
        // attach("attach2", [-1, 0, 0])
        translate([50+10+5/2, 0, 10+5/2])
        rot(from=[0, 0, 1], to=[-1, 0, 0])
        cube(
            size=[30, 100, 5],
            spin=0, anchor=LEFT);
            // orient=[-1.8369701987210297e-16, 0, -1.0],
            // anchor=[-1, 0, 0]);
