include <BOSL2/std.scad>
include <BOSL2/rounding.scad>

$fn = 50;

module half_fin(height, width, thickness, angle=0, spin=0, orient=UP, anchor=CENTER)
{
    little_x = thickness/2;
    little_hyp = little_x / cos(angle);
    little_y = abs(little_x * tan(angle));
    fin_length = height / cos(angle) + little_y*2;
    fin_x_disp = height * tan(angle);
    // echo(little_hyp*2+1);
    // echo(little_y*2);
    attachable(orient=orient, anchor=anchor, spin=spin) {
        union() {
            difference()
            {
                front_half() cuboid([thickness, fin_length, width], spin=-angle);
                fwd(height/2)
                left(fin_x_disp/2)
                cube([little_hyp*2+1, little_y*2, width+1], anchor=BACK);
            }
            // right(thickness/2)
            fwd(height/2)
            left(fin_x_disp/2)
            right(little_hyp)
            fillet(r=thickness,l=width, ang=90-angle); 
            fwd(height/2)
            left(fin_x_disp/2)
            left(little_hyp)
            mirror([1, 0, 0])
            fillet(r=thickness, l=width, ang=90+angle);
        }
        children();
    }
}

module full_fin(height, width, thickness, angle=0, spin=0, orient=UP, anchor=CENTER)
{
    fin_x_disp = height * tan(angle);
    anchor_list = [
        named_anchor("back", [fin_x_disp/2, height/2, 0]),
        named_anchor("front", [-fin_x_disp/2, -height/2, 0]),
    ];
    attachable(spin=spin, orient=orient, anchor=anchor, anchors=anchor_list) {
        union() {
            half_fin(height=height, width=width, thickness=thickness, angle=angle);
            xflip() yflip() half_fin(height=height, width=width, thickness=thickness, angle=angle);
        }
        children();
    }
}

module multiple_fins(n, spread, spacing, height, width, thickness, angle=0, spin=0, orient=UP, anchor=CENTER) {
    // only one of spacing or spread should be defined
    attachable(spin=spin, orient=orient, anchor=anchor, size=[0, height, width]) {
        xcopies(n=n, l=spread, spacing=spacing) full_fin(height=height, width=width, thickness=thickness, angle=angle);
        children();
    }
}

module fin_carrier(width=15, thickness=10, fin_thickness=1, fin_height=100, gap=1, fin_ang=10, fin_n=12) {
    hyp = (fin_height - gap) / cos(fin_ang);
    x_disp = hyp * sin(fin_ang);
    quarter_move = fin_thickness*3 * fin_n / 4 + thickness/2;
    half_move = quarter_move * 2;
    path = turtle([
        "move", quarter_move,
        "right", 90-fin_ang,
        "move", hyp,
        "left", 90-fin_ang,
        "move", half_move,
        "left", 90-fin_ang,
        "move", hyp,
        "right", 90-fin_ang,
        "move", quarter_move+thickness/2,
        "right", 90-fin_ang,
        "move", quarter_move,
        "right", fin_ang,
        "move", 10,
        ]);
    path_extrude2d(path, caps=false) {
        rect([thickness, width], anchor=CENTER);
    }
    right(13.2)
    fwd(thickness/2)
    multiple_fins(fin_n/4, spacing=3, height=fin_height, width=width, thickness=fin_thickness, angle=-fin_ang, anchor=BACK);
    back(thickness/2+gap)
    right(quarter_move + half_move)
    right(x_disp)
    left(5.5)
    multiple_fins(fin_n/2, spacing=3, height=fin_height, width=width, thickness=fin_thickness, angle=fin_ang, anchor=BACK);
    fwd(thickness/2)
    right(13.2)
    right(2 * half_move+quarter_move)
    right(x_disp/2)
    right(3)
    multiple_fins(fin_n/4, spacing=3, height=fin_height, width=width, thickness=fin_thickness, angle=-fin_ang, anchor=BACK);
}

module chassis() {
    fin_h = 100;
    gap = 1;
    fin_ang=10;
    thickness=10;
    down(15/2)
    {
        linear_extrude(15)
        difference() {
            w = 120;
            h = fin_h + gap + thickness;
            trapezoid(h=h+thickness*2, w1=w+20, ang=90+fin_ang);
            trapezoid(h=h, w1=w, ang=90+fin_ang);
        }
        left(70)
        back(50)
        fwd(0.5)
        up(15/2)
        fin_carrier();
    }
}
