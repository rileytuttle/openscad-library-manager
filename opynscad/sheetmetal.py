from opynscad import OPynScadWriter, WrappedObj
from dataclasses import dataclass, field
from typing import List
from dirs import *
from math import *

def polar_to_cart(r, theta):
    return [r*cos(theta*pi/180), r*sin(theta*pi/180)]

@dataclass
class SheetMetalBendConfig:
    metal_thickness: float
    ir: float
    ang: float
    edge_len: float
    bend: bool = False
    spin: float = 0
    orient: List = field(default_factory=lambda: UP)
    anchor: List = field(default_factory=lambda: CENTER)

class SheetMetalBend(WrappedObj):
    def __init__(self, config):
        super().__init__(includes=["rosetta-stone/sheet-metal.scad"], module_name="sheetmetal_bend", config=config)
        self.config = config
        self.unbent_size = 0
        self.bent_size = 0
        self.attach1_loc = [0, 0]
        self.attach2_loc = [0, 0]
        self.bent_attach1_loc = [0, 0]
        self.bent_attach2_dir = [0, 0]
    def process(self):
        self.bent_size = [2*(self.config.ir+self.config.metal_thickness),self.config.edge_len,2*(self.config.ir+self.config.metal_thickness)];
        self.unbent_size = [2*pi*self.config.ir*self.config.ang/360, self.config.edge_len, self.config.metal_thickness];
        self.attach2_loc = polar_to_cart(self.config.ir+self.config.metal_thickness/2, self.config.ang);
        self.bent_attach1_loc = polar_to_cart(self.config.ir+self.config.metal_thickness/2, 0);
        self.bent_attach2_dir = polar_to_cart(1, self.config.ang+90);
