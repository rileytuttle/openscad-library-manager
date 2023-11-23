from opynscad import OpynScadWriter
from sheetmetal import *

sheetmetal = SheetMetalNonBendable(size=[100, 100, 5], anchor=CENTER)

bend = SheetMetalBendableObj(5, 10, 90, 100, bend=False, anchor="attach1")
sheetmetal.attach("attach2", bend)
bend.bend()

second_flat_piece = SheetMetalNonBendable(size=[30, 100, 5], anchor=LEFT)
bend.attach("attach2", second_flat_piece)
sheetmetal.process()

scad = OpynScadWriter("test-sheetmetal-generation.scad")
scad.write(sheetmetal)

# sheetmetal_bend = SheetMetalBend(SheetMetalBendConfig(
# p
# p
