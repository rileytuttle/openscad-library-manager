include <BOSL2/std.scad>
// include <BOSL2/screws.scad>
include <rosetta-stone/std.scad>

$fn=50;

module handle(
    handle_mount_spacing=120,
    handle_height=20,
    handle_thickness=12,
    // screw_profile="M3",
    counterbore=20,
    // screw_length = 10, // this is just the meat the screw can grab not the head
    skinnyness_of_middle_fin=4,
    flat_dist = 60,
    anchor=CENTER, orient=UP, spin=0)
{
    fin_sweep = handle_height;
    up_dist = (handle_mount_spacing-flat_dist)/2;
    path = [
        [-handle_mount_spacing/2, 0],
        [-handle_mount_spacing/2, 5],
        [-handle_mount_spacing/2+up_dist, handle_height],
        [handle_mount_spacing/2-up_dist, handle_height],
        [handle_mount_spacing/2, 5],
        [handle_mount_spacing/2, 0]
    ];
    chamfer_to_fin = (handle_thickness-skinnyness_of_middle_fin)/2;
    attachable(anchor=anchor, orient=orient, spin=spin) {
        xrot(90)
        // diff("screw-remove") {
            intersect() {
                path_sweep2d(rect([handle_thickness, handle_thickness], chamfer=[1, chamfer_to_fin, chamfer_to_fin, 1]), path) {
                    path_sweep2d(apply(left(fin_sweep/2), rect([fin_sweep, skinnyness_of_middle_fin], chamfer=[0, 0, 0, 0])), path);
                    tag("intersect") cube([handle_mount_spacing+handle_thickness, handle_height*2, handle_thickness], anchor=FRONT);
                    // xcopies(n=2, l=handle_mount_spacing)
                    // tag("screw-remove") screw_hole(screw_profile, thread=false, head="socket", l=screw_length, anchor=BOTTOM, orient=BACK, counterbore=counterbore);
                }
            // }
        }
        children();
    }
}
