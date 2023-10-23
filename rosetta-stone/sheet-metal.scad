include <BOSL2/std.scad>
include <rosetta-stone/std.scad>

module sheetmetal_bend(metal_thickness, ir, ang, edge_len, bend=false, spin=0, anchor=CENTER, orient=UP)
{
    bent_size = [2*(ir+metal_thickness),edge_len,2*(ir+metal_thickness)];
    unbent_size = [2*PI*ir*ang/360, edge_len, metal_thickness];
    attach2_loc = polar_to_cart(ir+metal_thickness/2, ang);
    bent_attach1_loc = polar_to_cart(ir+metal_thickness/2, 0);
    bent_attach2_dir = polar_to_cart(1, ang+90);
    echo(attach2_loc);
    anchor_list = [
        if (bend) named_anchor("attach1", [bent_attach1_loc[0], 0, bent_attach1_loc[1]], orient=DOWN)
        else named_anchor("attach1", [-unbent_size[0]/2, 0, 0], orient=LEFT),
        if(bend) named_anchor("attach2", [attach2_loc[0], 0, attach2_loc[1]], orient=[bent_attach2_dir[0], 0, bent_attach2_dir[1]])
        else named_anchor("attach2", [unbent_size[0]/2, 0, metal_thickness/2], orient=RIGHT)
    ];
    attachable(spin=spin, anchor=anchor, orient=orient, size=bend?bent_size:unbent_size, anchors=anchor_list) {
        if(bend)
        {
            intersection() {
                tube(h=edge_len, ir=ir, wall=metal_thickness, anchor=CENTER, orient=FRONT);
                pie_slice(ang=ang, l=edge_len, r=ir+metal_thickness, anchor=CENTER, orient=FRONT);
            }
        }
        else
        {
            cube(unbent_size, anchor=CENTER);
        }
        children();
    }
}

