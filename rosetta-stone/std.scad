//      This library for misc 3d modelling utilities is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This may not be used for commericial purposes without consulting the original writer.

//     This library for misc 3d modelling utilities is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

//     You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>. 

include <../BOSL2/std.scad>
include <../BOSL2/rounding.scad>

INCH = 25.4;
amps_spacing = [30, 38];

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
    default_tag("remove")
    tag_scope()
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

module trapezoid3d(bottomwidth, topwidth, height, length, anchor=CENTER, spin=0, orient=UP, joint_top=0, joint_bot=0, joint_sides=0, chamfer=false) {
    splinesteps = chamfer ? 1 : 16;
    size = [bottomwidth, length, height];
    attachable(anchor=anchor, spin=spin, orient=orient, size=size) {
        rounded_prism(rect([bottomwidth, length]), rect([topwidth, length]), height=height, joint_top=joint_top, joint_bot=joint_bot, joint_sides=joint_sides, splinesteps=splinesteps);
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
    echo(str("major diam of hexagon is ", rad));
    attachable(size=[0, 0, height], anchor=anchor, spin=spin, orient=orient) {
        regular_polygon_3d(6, rad, height);
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
    // default_tag("remove")
    // tag_scope()
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


// note this will be 2 layers taller than l
// l is the unchanged hole dim
module floating_hole(d, l, channel_w, layer_height=0.2, anchor=CENTER, spin=0, orient=UP)
{
    channel_width = channel_w == undef ? d/3 : channel_w;
    default_tag("remove")
    attachable(anchor=anchor, orient=orient, spin=spin, size=[d, d, l]) {
        union() {
            cyl(d=d, l=l, anchor=CENTER);
            up(l/2)
            intersection() {
                cyl(d=d, l=layer_height, anchor=BOTTOM);
                cube([channel_width, d, layer_height], anchor=BOTTOM);
            }
            up(l/2 + layer_height)
            cube([channel_width, channel_width, layer_height], anchor=BOTTOM);
        }
        children();
    }
}

module floating_hole_nut_trap_inline(
    screw_profile,
    nut_info,
    d,
    l,
    layer_height=0.2,
    anchor=CENTER, spin=0, orient=UP)
{
    screw_info_struct = screw_info(screw_profile);
    diam = d == undef ? struct_val(screw_info_struct, "diameter") : d;
    head_size = struct_val(nut_info, "width");
    echo(str("screw head size: ", head_size));
    echo(str("screw shaft diam: ", diam));
    echo(nut_info);
    default_tag("remove")
    attachable(anchor=anchor, orient=orient, spin=spin, size=[head_size, head_size, l]) {
        union() {
            nut_trap_inline(l, screw_profile, anchor=CENTER);
            up(l/2)
            // intersection()
            {
                // nut_trap_inline(layer_height, screw_profile);
                cube([diam, head_size, layer_height], anchor=BOTTOM);
            }
            up(l/2 + layer_height)
            cube([diam, diam, layer_height], anchor=BOTTOM);
        }
        children();
    }
}
