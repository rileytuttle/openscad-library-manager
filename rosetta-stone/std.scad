include <BOSL2/std.scad>
include <BOSL2/rounding.scad>

module slot(d, spread, height=1, center=true, spin=0, round_radius=0) {
    slot_path = glued_circles(r=d/2, spread=spread, tangent=0);
    z_translate = center ? -height/2 : 0;
    translate([0,0,z_translate])
    offset_sweep(slot_path, height=height, bottom=os_teardrop(r=-round_radius), top=os_teardrop(r=-round_radius), spin=spin);
}
