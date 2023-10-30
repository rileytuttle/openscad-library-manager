include <BOSL2/std.scad>
include <rosetta-stone/std.scad>

module reflief_hole(diam, anchor, orient, spin=0) {
    assert($parent != undef);
    // attach to a parent geom anchor a hole of given size
    
}

module flatten() {
    path=[for(a=[-50:50]) [40, a]];
    color("red")
    dashed_stroke(path, [3,2], width = 1);
    projection(cut=false)
    children();
}

module sheetmetal_bend(metal_thickness, ir, ang, edge_len, bend=false, spin=0, anchor_to=CENTER, anchor=CENTER)
{
    if ($parent_geom != undef)
    {
        echo($parent_geom);
    }
    // TODO check for parent exists or something
    orientation = $parent_geom == undef ? UP : _find_anchor(anchor_to, $parent_geom)[2];
    echo(orientation);
    translation = $parent_geom == undef ? [0, 0, 0] : _find_anchor(anchor_to, $parent_geom)[1];
    bent_size = [2*(ir+metal_thickness),edge_len,2*(ir+metal_thickness)];
    unbent_size = [2*PI*ir*ang/360, edge_len, metal_thickness];
    attach2_loc = polar_to_cart(ir+metal_thickness/2, ang-90);
    bent_attach1_loc = polar_to_cart(ir+metal_thickness/2, 270);
    bent_attach2_dir = polar_to_cart(1, ang);
    // echo(attach2_loc);
    anchor_list = [
        if (bend) named_anchor("attach1", [bent_attach1_loc[0], 0, bent_attach1_loc[1]], orient=LEFT)
        else named_anchor("attach1", [-unbent_size[0]/2, 0, 0], orient=LEFT),
        if(bend) named_anchor("attach2", [attach2_loc[0], 0, attach2_loc[1]], orient=[bent_attach2_dir[0], 0, bent_attach2_dir[1]])
        else named_anchor("attach2", [unbent_size[0]/2, 0], orient=RIGHT)
    ];
    rotate_to = orientation;
    rotate_from = struct_val(anchor_list, anchor, default=UP);
    echo(str("rotate from: ", rotate_from, " rotate to: ", rotate_to));
    echo(anchor_list)
    // translate(translation)
    // rot(from=rotate_from, to=rotate_to)
    attachable(spin=spin, anchor=anchor, orient=UP, size=bend?bent_size:unbent_size, anchors=anchor_list) {
        if(bend)
        {
            rot(v=BACK, a=90)
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

