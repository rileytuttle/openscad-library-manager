include <BOLS2/std.scad>

module hinge_profile(
    inner_radius,
    bend_range,
    span_of_hinge,
    height_of_material_cut, // height of the material being cut
    cut_depth,
    number_of_fins,
    layer_height=0.2,
    layers_to_bend=2,
    minimum_gap=0.5,
    minimum_straight=0.5,
    fudge_factor=0.001,
    spin=0,
    anchor=CENTER,
    orient=UP) {
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

    attachable(spin=spin, anchor=anchor, orient=orient, size=[span_of_hinge,cut_depth, height_of_material_cut]) {
        rotate([90, 0, 0])
        translate([0, height_of_material_cut/2, -cut_depth/2])
        for (i=[0 : number_of_fins-1]) {
            translate([i*period - (span_of_hinge/2), 0, 0])
                linear_extrude(cut_depth)
                    translate([0,fudge_factor,0])
                    trapezoid(h=height_of_cut+fudge_factor, w1=0, w2 = top_length_of_fin, anchor=BACK+LEFT)
                        position(BACK)
                            square([minimum_gap, height_of_cut], anchor=BACK);
        }
        children();
    }
}
