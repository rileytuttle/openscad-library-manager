//      This library for ball bearing models is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This may not be used for commericial purposes without consulting the original writer.

//     This library for ball bearing models is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

//     You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>. 

include <BOSL2/std.scad>
include <BOSL2/screws.scad>

module bearing_channel(channel_radius, bearing_diam, spin=0, anchor=CENTER, orient=UP) {
    anchor_list = [
        named_anchor("fill-hole", [channel_radius, 0, 0]),
    ];
    attachable(spin=spin, anchor=anchor, orient=orient, size = [channel_radius*2, channel_radius*2, bearing_diam], anchors=anchor_list) {
        rotate_extrude() {
            translate([channel_radius, 0, 0])
            circle(d=bearing_diam);
        }
        children();
    }
}

module fill_plug(
    screw_name,
    threaded_length,
    nonthreaded_length,
    nonthreaded_diam,
    channel_bearing_diam,
    channel_radius,
    internal=false,
    spin=0, anchor=CENTER, orient=UP) {
    overall_length = threaded_length+nonthreaded_length;
    anchor_list = [
        // named_anchor("channel-flush", [0,0,-(overall_length/2)], orient=DOWN),
    ];
    attachable(spin=spin, anchor=anchor, orient=orient, size=[channel_bearing_diam, channel_bearing_diam, overall_length], anchors=anchor_list) {
        if (internal) {
            translate([0, 0, overall_length/2])
            diff("bearing-channel") {
                screw_hole(screw_name, l=threaded_length, thread=true, anchor=TOP)
                position(BOTTOM)
                cyl(l=nonthreaded_length, d=nonthreaded_diam, anchor=TOP)
                tag("bearing-channel") {
                    position(BOTTOM)
                    bearing_channel(channel_radius, channel_bearing_diam, anchor=LEFT);
                }
            }
        }
        else
        {
            translate([0, 0, overall_length/2])
            diff("bearing-channel") {
                screw(screw_name, l=threaded_length, drive="slot", anchor=TOP)
                position(BOTTOM)
                cyl(l=nonthreaded_length, d=nonthreaded_diam, anchor=TOP)
                tag("bearing-channel") {
                    position(BOTTOM)
                    bearing_channel(channel_radius, channel_bearing_diam, anchor=LEFT);
                }
            }
        }
        children();
    }
}

module sim_bearings(channel_radius, bearing_diam, n_bearings, anchor=CENTER, orient=UP, spin=0) {
    attachable(anchor=anchor, spin=spin, orient=orient, size=[2*channel_radius, 2*channel_radius, bearing_diam]) {
        color_this("grey") zrot_copies(n=n_bearings, r=channel_radius) {
            sphere(d=bearing_diam);
        }
        children();
    }
}

module bearing(spin=0, anchor=CENTER, orient=UP)
{
    attachable(anchor=anchor, spin=spin, orient=orient) {
        diff("remove") {
            cube([30, 30, 10], anchor=CENTER)
            tag("remove") {
                bearing_channel(10, channel_bearing_diam);
                tube(h=11, or=11, ir=9);
                
            }
            
        }
        children();
    }
}

module bearing_plate(
    plate_size,
    channel_bearing_diam,
    exposed_ball_portion,
    channel_radius,
    fill_plug_flat_height,
    fill_plug_screw_name,
    spin=0, anchor=CENTER, orient=UP) {
    screw_length = plate_size[2]-(channel_bearing_diam-exposed_ball_portion);
    anchor_list = [
        named_anchor("bearing-center", [0, 0, plate_size[2]/2-(channel_bearing_diam-exposed_ball_portion)+channel_bearing_diam/2]),
    ];
    attachable(spin=spin, anchor=anchor, orient=orient, size=plate_size, anchors=anchor_list) {
        diff("remove") {
            cube(plate_size, anchor=CENTER)
            tag("remove") {
                position(TOP)
                translate([0, 0, exposed_ball_portion])
                bearing_channel(channel_radius, channel_bearing_diam, anchor=TOP)
                    position("fill-hole")
                    // translate([20, 0, 0])
                    fill_plug(
                        fill_plug_screw_name,
                        screw_length,
                        fill_plug_flat_height,
                        channel_bearing_diam,
                        channel_bearing_diam,
                        channel_radius,
                        internal=true,
                        anchor=BOTTOM,
                        orient=DOWN);
                    // #fill_plug(
                    //     bearing_fill_plug_screw_name,
                    //     10,
                    //     10,
                    //     6,
                    //     6.25,
                    //     10,
                    //     internal=true);
            }
            // position("fill-hole")
            translate([20, 0, 0])
            #fill_plug(
                fill_plug_screw_name,
                screw_length,
                fill_plug_flat_height,
                channel_bearing_diam,
                channel_bearing_diam,
                channel_radius,
                internal=true);
                    // cyl(l=fill_plug_flat_height, d=channel_bearing_diam, anchor=TOP)
                    // position(BOTTOM)
                    // screw_hole(fill_plug_screw_name, thread=true, l=screw_length, anchor=TOP);
                    // tag("keep") {
                    //     position("fill-hole")
                    //     fill_plug(screw_name, threaded_portion, flat_height, flat_diam, anchor=BOTTOM, orient=DOWN);
                    // }
        }
                
        children();
    }
}

module example_bearing_plate() {
    screw_name = "M7-1";
    plate_size=[30,30,10];
    bearing_diam = 6;
    channel_bearing_diam = 6.25;
    roll_portion = 0.2; // percentage of ball exposed to be rolled on
    exposed_ball_portion = roll_portion * channel_bearing_diam;
    channel_radius = 9.75;
    n_bearings = 10;
    flat_height = 4;
    flat_diam = channel_bearing_diam-1;
    threaded_portion = plate_size[2] - (channel_bearing_diam-exposed_ball_portion)-(flat_height-channel_bearing_diam/2);
    bearing_plate(
        plate_size,
        channel_bearing_diam,
        exposed_ball_portion,
        channel_radius,
        flat_height,
        screw_name) {
        position("bearing-center")
        sim_bearings(channel_radius, bearing_diam, n_bearings);
        // position("bearing-center")
        // translate([channel_radius, 0, 0])
        // fill_plug(screw_name, threaded_portion, flat_height, flat_diam, channel_bearing_diam, channel_radius, anchor=BOTTOM, orient=DOWN);
    }
}
