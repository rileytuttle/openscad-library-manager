include <../BOSL2/std.scad>

module hexagonal_pattern(size=[100,100,10], hexagon_r=10, span=2, spin=0, orient=UP, anchor=CENTER) {
  echo(str("size=", size));
  nxcopies = ceil(size[0] / (hexagon_r + span/2)) + 1;
  nycopies = ceil(size[1] / (sqrt(3) * (hexagon_r + span/2))) + 1;
  echo(str(nxcopies, " hexagons in x direction"));
  echo(str(nycopies, " hexagons in y direction"));
  attachable(size=size, anchor=anchor, spin=spin, orient=orient) {
    linear_extrude(height=size[2], center=true)
    grid_copies(n=[nxcopies, nycopies], spacing=hexagon_r*2 + span, stagger=true) regular_ngon(n=6, ir=hexagon_r, spin=30);
    children();
  }
}

// diff()
// cuboid([100, 100, 5])
// tag_intersect("remove")
// cuboid([100-5, 100-5, 5+1])
// tag("intersect")
hexagonal_pattern(size=[100, 100, 5+1], hexagon_r=12, span=4);
