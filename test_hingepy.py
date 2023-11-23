from opynscad.hinges import HingeFin
from opynscad.opynscad import OpynScadWriter, Union

hinge_fin = HingeFin(20, 30, 5, 5, 0.4)
hinge_fin2 = HingeFin(20, 30, 5, 5, 0.4)
hinge_fin2.rotate([0, 0, 30])
hinge_fin2.translate([0, -10, 0])

fins = Union([hinge_fin, hinge_fin2])

scad = OpynScadWriter("test-hinges-py.scad")

scad.write(fins);

