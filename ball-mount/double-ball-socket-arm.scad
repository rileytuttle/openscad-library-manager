//      This library for ball mount models is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This may not be used for commericial purposes without consulting the original writer.

//     This library for ball mount models is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

//     You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>. 

include <rosetta-stone/ball-mount-bits.scad>

// the resolution of the model. use lower resolution for quick compile times while iterating. then increase before generating stl.
$fn=50;

// the diameter of the ball in mm. the module should already factor in a 10% increase in diam
ball_diameter = 25.5;
// the length of the arm from ball center to center. check terminal output for full tip to tip length.
length = 55;
// the additional thickness added for strength
thickness = 0;
// the type of screw to be used. defined here https://github.com/BelfrySCAD/BOSL2/wiki/screws.scad#subsection-screw-naming. ie metric "M6" us "1/4" or "5/16"
screw_type = "1/4";
// whether or not to cut a nut trap on the bottom. I use this for one side. bottom has a nut trap and the other side does not because it will have some kind of wing nut
nut_trap = true;
// whether or not to add a spring detent. this should probably be false for now because I need to be specific about how far down to cut so we have precise compression
spring = false;
// diameter of the spring to be used will not be used if there is no spring
spring_diam = 6.75;

double_socket(ball_diameter, length, thickness, screw_type, nut_trap, spring, spring_diam);
