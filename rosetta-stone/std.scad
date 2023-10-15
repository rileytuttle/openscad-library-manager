include <BOSL2/std.scad>
include <BOSL2/rounding.scad>

INCH = 25.4;

function mm_to_in(mm) = mm * 0.0393701;
function in_to_mm(in) = in * 25.4;

function get_sequential_anchor_names(prefix, number_of_anchors=4) = [
        for (i=[0:number_of_anchors-1]) str(prefix,i)
    ];

module slot(d, h, spread, spin=0, round_radius=0, anchor=CENTER, spin=0, orient=UP) {   
    slot_path = glued_circles(r=d/2, spread=spread, tangent=0);
    attachable(anchor=anchor, spin=spin, orient=orient, size=[spread+d, d, h]) {
        rotate([180,0,0])
        translate([0,0,-h/2])
        offset_sweep(slot_path, height=h, bottom=os_teardrop(r=-round_radius), top=os_teardrop(r=-round_radius));
        children();
    }
}

// module triangle3d(bottomwidth, height, anchor=CENTER, spin=0, orient=UP) {
//     attachable(anchor=anchor, spin=spin, orient=orient) {
        
//         prismoid(size1=[bottomwidth, height], size2=[0, height]);
//         children();
//     }
// }

module trapezoid3d(bottomwidth, topwidth, height, anchor=CENTER, spin=0, orient=UP) {
    attachable(anchor=anchor, spin=spin, orient=orient) {
        prismoid(size1=[bottomwidth, height], size2=[topwidth, height]);
        children();
    }
}
