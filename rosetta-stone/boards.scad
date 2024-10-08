//      This library for board mounting models is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This may not be used for commericial purposes without consulting the original writer.

//     This library for board mounting models is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

//     You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>. 

include <BOSL2/std.scad>
include <rosetta-stone/std.scad>

function get_mount_hole_locs(hole_spacings, offsets=[0,0]) = [
        // assumes 2D spacings and offsets
        for (i=[-hole_spacings[0]/2,hole_spacings[0]/2], j=[-hole_spacings[1]/2, hole_spacings[1]/2]) [i+offsets[0], j+offsets[1], 0]
    ];

// hole mask masks out holes
// hole_mask[0] top left
// hole_mask[1] bottom left
// hole_mask[2] bottom right
// hole_mask[3] top right
module simulated_4_hole_board(size, mount_hole_spacing=[0,0], mount_hole_diam, mount_hole_offset=[0,0], anchor=CENTER, spin=0, orient=UP, hole_mask = [1, 1, 1, 1]) {
    mount_hole_locs = get_mount_hole_locs(mount_hole_spacing, mount_hole_offset);
    mount_hole_names = [
        "mount_hole1",
        "mount_hole2",
        "mount_hole3",
        "mount_hole4",
    ];
    anchor_list = [
        for (i=[0:4-1]) if(hole_mask[i]) named_anchor(mount_hole_names[i], mount_hole_locs[i])
    ];
    attachable(anchor=anchor, spin=spin, orient=orient, size=size, anchors=anchor_list) {
        diff("mount-holes"){
        cube(size=size, anchor=CENTER) {
            tag("mount-holes") {
            for (i=[0:4-1]) {
                if (hole_mask[i]) {
                    loc=mount_hole_locs[i];
                    position(CENTER)
                    translate(loc)
                    cyl(d=mount_hole_diam, l=size[2]+1, anchor=CENTER);
                }
            }}
        }}
        children();
    }
}

module standoffs4(size2d, l, d, anchor=CENTER, spin=0, orient=UP, rounding=0, standoff_mask=[1,1,1,1]) {
    standoff_locs = get_mount_hole_locs(size2d);
    standoff_names = [
        "standoff1",
        "standoff2",
        "standoff3",
        "standoff4",
    ];
    anchor_list = [
        for (i=[0:4-1]) if(standoff_mask[i]) named_anchor(standoff_names[i], standoff_locs[i])
    ];
    attachable(anchor=anchor, spin=spin, orient=orient, size=[size2d[0]+d, size2d[1]+d, l], anchors=anchor_list) {
        for (i=[0:4-1]) {
            if (standoff_mask[i]) {
                loc=standoff_locs[i];
                translate(loc)
                cyl(d=d, l=l, anchor=CENTER, rounding1=rounding);
            }
        }
        children();
    }
}

module mount_holes4(size2d, l, d, anchor=CENTER, spin=0, orient=UP, mount_hole_mask=[1,1,1,1]) {
    mount_hole_locs = get_mount_hole_locs(size2d);
    mount_hole_names = [
        "mount_hole1",
        "mount_hole2",
        "mount_hole3",
        "mount_hole4",
    ];
    anchor_list = [
        for (i=[0:4-1]) if(mount_hole_mask[i]) named_anchor(mount_hole_names[i], mount_hole_locs[i])
    ];
    attachable(anchor=anchor, spin=spin, orient=orient, size=[size2d[0]+d, size2d[1]+d, l], anchors=anchor_list) {
        for (i=[0:4-1]) {
            if (mount_hole_mask[i]) {
                loc=mount_hole_locs[i];
                translate(loc)
                cyl(d=d, l=l, anchor=CENTER);
            }
        }
        children();
    }
}
module mount_threads4(spec, size, anchor=CENTER, threaded=true, spin=0, orient=UP, mount_hole_mask=[1,1,1,1]) {
    d = struct_val(spec, "diameter") == undef ?
        struct_val(screw_info(spec), "diameter") :
        struct_val(spec, "diameter");
    mount_hole_locs = get_mount_hole_locs([size[0], size[1]]);
    mount_hole_names = [
        "mount_hole1",
        "mount_hole2",
        "mount_hole3",
        "mount_hole4",
    ];
    anchor_list = [
        for (i=[0:4-1]) if(mount_hole_mask[i]) named_anchor(mount_hole_names[i], mount_hole_locs[i])
    ];
    attachable(anchor=anchor, spin=spin, orient=orient, size=[size[0]+d, size[1]+d, size[2]], anchors=anchor_list) {
        for (i=[0:4-1]) {
            if (mount_hole_mask[i]) {
                loc=mount_hole_locs[i];
                translate(loc)
                screw_hole(spec=spec, thread=threaded, bevel2=true, anchor=CENTER, length=size[2]);
            }
        }
        children();
    }
}

