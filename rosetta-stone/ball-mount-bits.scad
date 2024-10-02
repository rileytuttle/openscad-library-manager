include <BOSL2/std.scad>
include <BOSL2/screws.scad>
include <BOSL2/rounding.scad>


// probably should work on adding ribs to it
module circular_base_with_post(post_d, ball_d, platform_size, neck_size, flare_neck_bottom=0, anchor=CENTER, orient=UP, spin=0) {
    push_up_neck = 5;
    size=[platform_size[0], platform_size[0], neck_size[1]+ball_d+platform_size[1] - push_up_neck];
    ball_center_h = neck_size[1] - push_up_neck + platform_size[1] - size[2]/2 + ball_d/2;
    anchor_list = [
        // named_anchor("ball-center", [0, 0, platform_size[1]+neck_size[1]+push_up_neck]),
        named_anchor("ball-center", [0, 0, ball_center_h]),
    ];
    attachable(orient=orient, anchor=anchor, spin=spin, size=size, anchors=anchor_list) {
        // up(neck_size[1] - push_up_neck + platform_size[1])
        // down(size[2]/2)
        up(ball_center_h-ball_d/2)
        intersect("onion", "else") {
            cyl(d=neck_size[0], l=ball_d, anchor=TOP, orient=DOWN) {
                tag("onion") onion(d=ball_d);
                tag("else")
                down(push_up_neck)
                // neck
                position(TOP) cyl(d=neck_size[0], l=neck_size[1], anchor=TOP, rounding1=flare_neck_bottom, orient=DOWN) {
                    // base
                    position(BOTTOM) cyl(d=platform_size[0], l=platform_size[1], anchor=TOP, rounding2=2);
                }
            }
        }
        children();
    }
}

module ball_with_circular_base(ball_d, platform_size, neck_size, flare_neck_bottom=0, anchor=CENTER, orient=UP, spin=0) {
    push_up_neck = 5;
    size=[platform_size[0], platform_size[0], neck_size[1]+ball_d+platform_size[1] - push_up_neck];
    ball_center_h = neck_size[1] - push_up_neck + platform_size[1] - size[2]/2 + ball_d/2;
    anchor_list = [
        // named_anchor("ball-center", [0, 0, platform_size[1]+neck_size[1]+push_up_neck]),
        named_anchor("ball-center", [0, 0, ball_center_h]),
    ];
    attachable(orient=orient, anchor=anchor, spin=spin, size=size, anchors=anchor_list) {
        // up(neck_size[1] - push_up_neck + platform_size[1])
        // down(size[2]/2)
        up(ball_center_h-ball_d/2)
        onion(d=ball_d, anchor=TOP, orient=DOWN) {
            down(push_up_neck)
            // neck
            position(TOP) cyl(d=neck_size[0], l=neck_size[1], anchor=TOP, rounding1=flare_neck_bottom, orient=DOWN) {
                // base
                position(BOTTOM) cyl(d=platform_size[0], l=platform_size[1], anchor=TOP, rounding2=2);
            }
        }
        children();
    }
}


// example
// double_socket(25.5, 75, "1/4,20", nut_trap=false, offset_spring=true);
// l should be the ball center to center length
module double_socket(ball_d, l, thickness=0, screw_profile="1/4,20", nut_trap=true, offset_spring=false, spring_diam=6.75, anchor=CENTER, orient=UP, spin=0) {
    ball_increase_factor = 1;
    ball_to_edge_dist = 0;
    size = [l + ball_d*0.9 + ball_to_edge_dist*2, ball_d*0.9, ball_d + thickness];
    gap=3;
    echo(str("overall length = ", size[0], "mm"));
    attachable(anchor=anchor, orient=orient, spin=spin, size=size) {
        bottom_half(size[0]+1)
        up(gap/2)
        diff() {
            cuboid(size, anchor=CENTER, rounding=3, teardrop=true)
            {
                socket_offset = l;
                tag("remove")
                zrot_copies(n=2, d=socket_offset) {
                    ball_decrease_factor = 0.7;
                    sphere(d=ball_d);
                    cyl(d=ball_d * ball_decrease_factor, l=50, orient=BACK)
                    position(RIGHT)
                    cube([ball_d * ball_decrease_factor, ball_d * ball_decrease_factor, ball_d*2], anchor=CENTER);
                }
                screw_hole(screw_profile, thread=false, l=35);
                if(nut_trap) {
                    position(BOTTOM)
                    nut_trap_inline(4, screw_profile);
                }
                if (offset_spring)
                {
                    down(gap/2)
                    right(9)
                    tag("remove") cyl(d=spring_diam, l=1.5, anchor=TOP);
                }
            }
        }
        children();
    }
}

module double_ball_adapter(
    ball1_d,
    ball2_d,
    l, // l is defined as the center to center dist
    shaft_d=10,
    teardrop_angs = [90, 90], // 90 is the same as no teardrop and can go down to > 0
    anchor=CENTER, orient=UP, spin=0)
{
    assert(shaft_d < min(ball1_d, ball2_d));
    assert(l > (ball1_d+ball2_d)/2);
    overall_length = l+(ball1_d+ball2_d)/2;
    bigger_ball_d = max(ball1_d, ball2_d);
    bigger_ball_r = bigger_ball_d/2;
    small_ball_d = min(ball1_d, ball2_d);
    // bottom_cut_off_d = min(max(bigger_ball_d * 0.4, 7.5), 15);
    // echo(str("base diamenter = ", bottom_cut_off_d));
    // bottom_cut_off_r = bottom_cut_off_d/2;
    // push_over = bigger_ball_r - sqrt(bigger_ball_r^2 - bottom_cut_off_r^2);
    // echo(str("push over amount = ", push_over));
    attachable(anchor=anchor, orient=orient, spin=spin, size=[overall_length, bigger_ball_d, bigger_ball_d])
    {
        // left(l/2 + bigger_ball_d/2 - push_over)
        // right_half()
        // left(push_over)
        // right(l/2 + bigger_ball_d/2)
        cyl(d=shaft_d, l=l, orient=RIGHT) {
            position(BOTTOM)
            onion(d=bigger_ball_d, orient=DOWN, ang=teardrop_angs[0]);
            position(TOP)
            onion(d=small_ball_d, orient=DOWN, ang=teardrop_angs[1]);
        }
        children();
    }
}

module extension(
    ball_d,
    l, // l is defined as center to center
    shaft_d=10,
    teardrop_angs = [90, 90],
    orient=UP, anchor=CENTER, spin=0) {
    size = [l + ball_d, ball_d, ball_d];
    attachable(size=size, anchor=anchor, orient=orient, spin=spin) {
        double_ball_adapter(ball_d, ball_d, l=l, shaft_d=shaft_d, teardrop_angs=teardrop_angs);
        children();
    }
}

// example
// wingnut();
module wingnut(
    screw_profile="1/4,20",
    size=[40, 15, 30], // [overall length, thickness must be wider than screw profile, overall height]
    orient=UP, anchor=CENTER, spin=0)
{
    width = size[0];
    thickness = size[1];
    height = size[2];
    thread_spec = screw_info(screw_profile);
    screw_hole_diam = struct_val(thread_spec, "diameter");
    assert(width > 2 * thickness);
    assert(thickness > screw_hole_diam + 2); // leaves at least 1 mm on each side
    attachable(size=size, anchor=anchor, orient=orient, spin=spin) {
        diff() {
            rounded_prism(rect([thickness, thickness], rounding=5), rect([width, thickness], rounding=5), l=height, joint_top=3, joint_bot=3) {
                tag("remove") screw_hole(screw_profile, thread=true, l=height);
            }
        }
        children();
    }
}
