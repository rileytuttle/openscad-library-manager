from opynscad import WrappedObj
from dirs import *
from math import *

def polar_to_cart(r, theta):
    return [r*cos(theta*pi/180), r*sin(theta*pi/180)]

class SheetMetalBend(WrappedObj):
    def __init__(
        self,
        metal_thickness,
        ir,
        ang,
        edge_len,
        bend=False,
        spin = 0,
        orient = UP,
        anchor = CENTER):
        self.config = {
            "metal_thickness":metal_thickness,
            "ir":ir,
            "ang":ang,
            "edge_len":edge_len,
            "bend":bend,
            "spin":spin,
            "orient":UP,
            "anchor":CENTER
        }
        super().__init__(includes=["rosetta-stone/sheet-metal.scad"], module_name="sheetmetal_bend")
    def process(self):
        self.bent_size = [2*(self.config["ir"]+self.config["metal_thickness"]),self.config["edge_len"],2*(self.config["ir"]+self.config["metal_thickness"])];
        self.unbent_size = [2*pi*self.config["ir"]*self.config["ang"]/360, self.config["edge_len"], self.config["metal_thickness"]];
        self.attach2_loc = polar_to_cart(self.config["ir"]+self.config["metal_thickness"]/2, self.config["ang"]);
        self.bent_attach1_loc = polar_to_cart(self.config["ir"]+self.config["metal_thickness"]/2, 0);
        self.bent_attach2_dir = polar_to_cart(1, self.config["ang"]+90);
