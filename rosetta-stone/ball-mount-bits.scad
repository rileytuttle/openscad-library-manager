include <BOSL2/std.scad>
include <BOSL2/screws.scad>
include <BOSL2/rounding.scad>

module ball_with_circular_base(ball_d, platform_size, neck_size, flare_neck_bottom=0, anchor=CENTER, orient=UP, spin=0) {
    push_up_neck = 5;
    size=[platform_size[0], platform_size[0], neck_size[1]+ball_d+platform_size[1] - push_up_neck];
    attachable(orient=orient, anchor=anchor, spin=spin, size=size) {
        up(neck_size[1] - push_up_neck + platform_size[1])
        down(size[2]/2)
        sphere(d=ball_d, anchor=BOTTOM) {
            up(push_up_neck)
            // neck
            position(BOTTOM) cyl(d=neck_size[0], l=neck_size[1], anchor=TOP, rounding1=flare_neck_bottom) {
                // base
                position(BOTTOM) cyl(d=platform_size[0], l=platform_size[1], anchor=TOP, rounding2=2);
            }
        }
        children();
    }
}


// example
// double_socket(25.5, 75, "1/4,20", nut_trap=false, offset_spring=true);
module double_socket(ball_d, l, screw_profile="1/4,20", nut_trap=true, offset_spring=false, spring_diam=6.75, anchor=CENTER, orient=UP, spin=0) {
    ball_increase_factor = 1.1;
    size = [l, ball_d*0.9, ball_d * ball_increase_factor];
    gap=3;
    attachable(anchor=anchor, orient=orient, spin=spin, size=size) {
        bottom_half()
        up(gap/2)
        diff() {
            cuboid(size, anchor=CENTER, rounding=3, teardrop=true) {
                socket_offset = l-ball_d + 4;
                tag("remove")
                zrot_copies(n=2, d=socket_offset) {
                    ball_decrease_factor = 0.7;
                    sphere(d=ball_d);
                    cyl(d=ball_d * ball_decrease_factor, l=50, orient=BACK)
                    position(RIGHT)
                    cube([ball_d * ball_decrease_factor, ball_d * ball_decrease_factor, 50], anchor=CENTER);
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
// wing_nut();
module wing_nut(
    screw_profile="1/4,20",
    orient=UP, anchor=CENTER, spin=0)
{
    width = 40;
    thickness = 15;
    height = 30;
    size=[width, thickness, height];
    attachable(size=size, anchor=anchor, orient=orient, spin=spin) {
        diff() {
            rounded_prism(rect([thickness, thickness], rounding=5), rect([width, thickness], rounding=5), l=height, joint_top=3, joint_bot=3) {
                tag("remove") screw_hole(screw_profile, thread=true, l=height);
            }
        }
        children();
    }
}

