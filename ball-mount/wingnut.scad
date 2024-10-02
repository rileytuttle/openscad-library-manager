//      This library for ball mount models is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This may not be used for commericial purposes without consulting the original writer.

//     This library for ball mount models is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

//     You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>. 

include <rosetta-stone/ball-mount-bits.scad>

// the resolution of the model. use lower resolution for faster compilation while testing
$fn=50; // [10:100]
// the type of screw to be used. defined here https://github.com/BelfrySCAD/BOSL2/wiki/screws.scad#subsection-screw-naming. ie metric "M6x1.0" us "1/4,20" or "5/16,18"
screw_profile="5/16,18";
// rough size of the wingnut [overall length, thickness must be wider than screw profile, overall height]
size = [40, 15, 20];

wingnut(screw_profile, size);
