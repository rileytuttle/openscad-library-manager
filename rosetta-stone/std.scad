include <BOSL2/std.scad>
include <BOSL2/rounding.scad>

INCH = 25.4;

function mm_to_in(mm) = mm * 0.0393701;
function in_to_mm(in) = in * 25.4;

function polar_to_cart(r, theta) = [r*cos(theta), r*sin(theta)];
function cart_to_polar(x, y) = [sqrt(x^2+y^2), atan(y/x)];

function get_sequential_anchor_names(prefix, number_of_anchors=4) = [
        for (i=[0:number_of_anchors-1]) str(prefix,i)
    ];

function rotate_coords(coords, angle) = [
    coords[0] * cos(angle) - coords[1] * sin(angle),
    coords[0] * sin(angle) + coords[1] * cos(angle)
];

function dist_between_points2d(p1, p2) = sqrt((p1[0]-p2[0])^2 + (p1[1]-p2[1])^2);
function angle_between_points2d(p1, p2) = atan2(p2[1]-p1[1],p2[0]-p1[0]);

module slot(d, h, spread, spin=0, round_radius=0, anchor=CENTER, spin=0, orient=UP) {   
    slot_path = glued_circles(r=d/2, spread=spread, tangent=0);
    attachable(anchor=anchor, spin=spin, orient=orient, size=[spread+d, d, h]) {
        rotate([180,0,0])
        translate([0,0,-h/2])
        offset_sweep(slot_path, height=h, bottom=os_teardrop(r=-round_radius), top=os_teardrop(r=-round_radius));
        children();
    }
}

// module triangle3d(bottomwidth, height, anchor=CENTER, spin=0, orient=UP) {
//     attachable(anchor=anchor, spin=spin, orient=orient) {
        
//         prismoid(size1=[bottomwidth, height], size2=[0, height]);
//         children();
//     }
// }

module trapezoid3d(bottomwidth, topwidth, height, length, anchor=CENTER, spin=0, orient=UP) {
    attachable(anchor=anchor, spin=spin, orient=orient) {
        prismoid(size1=[bottomwidth, height], size2=[topwidth, height], height=length);
        children();
    }
}

module regular_polygon_3d(sides, r, height, spin=0, orient=UP, anchor=CENTER)
{
    attachable(spin=spin, orient=orient, anchor=anchor, size=[2*r, 2*r, height]) {
        down(height/2)
        linear_extrude(height) {
            circle(r=r, $fn=sides);
        }
        children();
    }
}

module hexagon3d(r,minor_width,height,spin=0, orient=UP, anchor=CENTER)
{
    assert(!(r == undef && minor_width == undef));
    rad = r==undef ?
        minor_width / (2 * sin(60)) :
        r;
    attachable(spin=spin, orient=orient, anchor=anchor, size=[2*rad, 2*rad, height]) {
        regular_polygon_3d(6, rad, height, spin=spin, orient=orient, anchor=anchor);
        children();
    }
    
}

module magnet_cutout_cyl(
    mag_d, // magnet diam
    mag_l, // magnet height
    l, // overall length that we want to cut, used for viewing window
    layerheight=0.2, // assumed printer layer height
    n_layers_to_surface=2, // number of layers between the magnet and the surface
    viewing_window=true, // should there be a viewing window to the magnet
    viewing_gap=2, // how wide should the viewing window be
    anchor=CENTER,
    spin=0,
    orient=UP) {
    attachable(size=[mag_d, mag_d, l], spin=spin, anchor=anchor, orient=orient) {
        intersect(intersect="mag-intersect", keep="mag-keep") {
            cyl(d=mag_d, l=l, anchor=CENTER) {
                tag("mag-intersect") cube([viewing_gap, mag_d, l], anchor=CENTER);
                position(TOP)
                down(layerheight*n_layers_to_surface)
                tag("mag-keep") cyl(d=mag_d, l=mag_l, anchor=TOP);
            }
        }
        children();
    }
}

// cuboid where the bottom and top rounding can have mixed sign
// for example cutting a pocket in something can could have a positive rounded edge at the bottom and negative at the top
module mixed_rounding_cuboid() {
}
