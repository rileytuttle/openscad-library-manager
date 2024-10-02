include <ikea_skadis.scad>
include <rosetta-stone/std.scad>
// see https://github.com/franpoli/OpenSCADutil/blob/master/libraries/ikea_skadis_pegboard/accessories/README.org

module rskadis_u_holder(d, retainer, fullfill, thickness)
{
    attachable()
    {
        skadis_u_holder(d=d, retainer=retainer, fullfill=fullfill, thickness=thickness);
        children();
    }
}

module rskadis_plier()
{
}

module tslot_seat(h=20, anchor=BOTTOM, orient=UP, spin=0)
{
    spread=10.1;
    slot_d = 5.05;
    cyl_dtop = 22;
    cyl_dbottom = 16;
    cyl_up = 2;
    default_tag("remove")
    attachable(size=[cyl_dtop, cyl_dtop, h], anchor=anchor, orient=orient, spin=spin) {
        slot(d=slot_d, h=h, spread=spread, spin=90) {
            position(BOTTOM) up(cyl_up) cyl(d1=cyl_dbottom, d2=cyl_dtop, l=5-cyl_up, anchor=BOTTOM)
            position(TOP) cyl(d=cyl_dtop, h=h-5, anchor=BOTTOM);
        }
        children();
    }
}
