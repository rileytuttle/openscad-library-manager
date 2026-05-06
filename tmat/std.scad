include <../BOSL2/std.scad>
include <../rosetta-stone/std.scad>

tmat_height = 0.68 * INCH;
tmat_x_width = 0.475 * INCH;
tmat_x_length = 36;
tmat_x_box_width = 0.75 * INCH;

module tmatx(screw_mount=false, anchor=CENTER, orient=UP, spin=0) {
  cube_width=tmat_x_length / sqrt(2);
  chamfer_amount = 2;
  attachable(anchor=anchor, orient=orient, spin=spin, size=[cube_width, cube_width, tmat_height]) {
    // main center cube
    cuboid([tmat_x_box_width, tmat_x_box_width, tmat_height], chamfer=chamfer_amount, edges=TOP) {
      zrot_copies(rots=[45, -45])
        // x legs
        cuboid([tmat_x_length, tmat_x_width, tmat_height], chamfer=chamfer_amount, edges=[TOP+FRONT, TOP+BACK])
        // rounded ends
        xcopies(n=2, spacing=tmat_x_length) cyl(d=tmat_x_width, l=tmat_height, chamfer2=chamfer_amount);
    }
    children();
  }
}
