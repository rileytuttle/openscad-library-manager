include <BOSL2/std.scad>

module extension(ball_d, l, orient=UP, anchor=CENTER, spin=0) {
    attachable(orient=orient, anchor=anchor, spin=spin, size=[ball_d*2+l, ball_d, ball_d]) {
        union() {
            xcopies(n=2, l=l+ball_d) {
                sphere(d=ball_d);
            }
            cyl(orient=RIGHT, d=10, l=l+ball_d);
        }
        children();
    }
}

module ball_with_circular_base(ball_d, platform_size, neck_size, anchor=CENTER, orient=UP, spin=0) {
    push_up_neck = 5;
    size=[platform_size[0], platform_size[0], neck_size[1]+ball_d+platform_size[1] - push_up_neck];
    attachable(orient=orient, anchor=anchor, spin=spin, size=size) {
        up(neck_size[1] - push_up_neck + platform_size[1])
        down(size[2]/2)
        sphere(d=ball_d, anchor=BOTTOM) {
            up(push_up_neck)
            // neck
            position(BOTTOM) cyl(d=neck_size[0], l=neck_size[1], anchor=TOP, rounding1=-10) {
                // base
                position(BOTTOM) cyl(d=platform_size[0], l=platform_size[1], anchor=TOP, rounding2=2);
            }
        }
        children();
    }
}
