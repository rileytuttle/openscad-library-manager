include <BOSL2/std.scad>
include <BOSL2/rounding.scad>

module simulated_4_hole_board(size, mount_hole_h_spacing, mount_hole_v_spacing, mount_hole_diam, mount_hole_h_offset=0, mount_hole_v_offset=0, anchor=CENTER, spin=0, orient=UP) {
    mount_hole_locs = [
        for (i=[-mount_hole_h_spacing/2,mount_hole_h_spacing/2], j=[-mount_hole_v_spacing/2, mount_hole_v_spacing/2]) [i+mount_hole_h_offset, j+mount_hole_v_offset, 0]
    ];
    mount_hole_names = [
        "mount_hole1",
        "mount_hole2",
        "mount_hole3",
        "mount_hole4",
    ];
    anchor_list = [
        for (i=[0:4-1]) named_anchor(mount_hole_names[i], mount_hole_locs[i])
    ];
    for (my_anchor=anchor_list) {
        echo(my_anchor);
    }
    attachable(anchor=anchor, spin=spin, orient=orient, size=size, anchors=anchor_list) {
        diff("mount-holes"){
        cube(size=size, anchor=CENTER) {
            tag("mount-holes") {
            for (loc=mount_hole_locs) {
                position(CENTER)
                translate(loc)
                cyl(d=mount_hole_diam, l=size[2]+1, anchor=CENTER);
            }}
        }}
        children();
    }
}

module standoffs4(width, height, l, d, anchor=CENTER, spin=0, orient=UP, rounding=0) {
    standoff_locs = [
        for (i=[-width/2,width/2], j=[-height/2, height/2]) [i, j, 0]
    ];
    standoff_names = [
        "standoff1",
        "standoff2",
        "standoff3",
        "standoff4",
    ];
    anchor_list = [
        for (i=[0:4-1]) named_anchor(standoff_names[i], standoff_locs[i])
    ];
    attachable(anchor=anchor, spin=spin, orient=orient, size=[width+d, height+d, l], anchors=anchor_list) {
        for (loc=standoff_locs) {
            translate(loc)
            cyl(d=d, l=l, anchor=CENTER, rounding1=rounding);
        }
        children();
    }
}

module mount_holes4(width, height, l, d, anchor=CENTER, spin=0, orient=UP) {
    mount_hole_locs = [
        for (i=[-width/2,width/2], j=[-height/2, height/2]) [i, j, 0]
    ];
    mount_hole_names = [
        "mount_hole1",
        "mount_hole2",
        "mount_hole3",
        "mount_hole4",
    ];
    anchor_list = [
        for (i=[0:4-1]) named_anchor(mount_hole_names[i], mount_hole_locs[i])
    ];
    attachable(anchor=anchor, spin=spin, orient=orient, size=[width+d, height+d, l], anchors=anchor_list) {
        for (loc=mount_hole_locs) {
            translate(loc)
            cyl(d=d, l=l, anchor=CENTER);
        }
        children();
    }
}

module slot(d, h, spread, spin=0, round_radius=0, anchor=CENTER, spin=0, orient=UP) {
    slot_path = glued_circles(r=d/2, spread=spread, tangent=0);
    attachable(anchor=anchor, spin=spin, orient=orient, size=[spread+d, d, h]) {
        rotate([180,0,0])
        translate([0,0,-h/2])
        offset_sweep(slot_path, height=h, bottom=os_teardrop(r=-round_radius), top=os_teardrop(r=-round_radius));
        children();
    }
}

module hinge_profile(inner_radius, bend_range, span_of_hinge, height_of_material_cut, cut_depth, number_of_fins, layer_height=0.2, layers_to_bend=2, minimum_gap=0.5, minimum_straight=0.5, fudge_factor=0.001) {
    angle_per_fin = bend_range / number_of_fins;
    material_left = layers_to_bend*layer_height;
    height_of_cut = height_of_material_cut - material_left;
    top_length_of_fin = 2*tan(angle_per_fin / 2)*height_of_cut + minimum_gap;
    gap_between_fins = (span_of_hinge - number_of_fins * top_length_of_fin) / (number_of_fins - 1);
    period = gap_between_fins + top_length_of_fin;
    // echo("angle per fin", angle_per_fin);
    // echo("material left", material_left);
    // echo("height of material cut", height_of_material_cut);
    // echo("top length of fin", top_length_of_fin);

    for (i=[0 : number_of_fins-1]) {
        translate([i*period - (span_of_hinge/2), 0, 0])
            linear_extrude(cut_depth)
                translate([0,fudge_factor,0])
                trapezoid(h=height_of_cut+fudge_factor, w1=0, w2 = top_length_of_fin, anchor=BACK+LEFT)
                    position(BACK)
                        square([minimum_gap, height_of_cut], anchor=BACK);
    }
}
