from opynscad import WrappedObj, AttachableUnion
from dirs import *
from math import *

def polar_to_cart(r, theta):
    return [r*cos(theta*pi/180), r*sin(theta*pi/180)]

"""
    sheetmetal object
    should always be something roughly a cube
    this clas should be extended with it's own process method
    that recalculates anchor points (possibly just orientations)
    and then calls this parents process function to propagate the information down
    to the attached geometries
"""
class SheetMetalObj(WrappedObj):
    def __init__(self, includes=[], uses=[], module_name=None):
        super().__init__(includes=includes, uses=uses, module_name = module_name)
        self.anchors = dict()
        self.anchored_to = dict() # dictionary of what we are anchored to and the orientation (as given by the thing we are attached to)
        self.attached_geoms = []
    """
    attach something at a specific anchor point
    anchor is going to be an anchor and orientation
    """
    def attach(self, anchorname, geom):
        self.attached_geoms += {"anchorname" : anchorname, "geom": geom}
        geom.give_attach_info(self.anchors[anchorname])
    """
    give this bend information about it's anchor point
    anchor is a dict with key = anchorname
    and then location and orientation
    """
    def give_attach_info(self, anchor):
        self.anchored_to = anchorname

    def get_sheetmetal_description(self):
        sheetmetal_description = get_base_descriptor()
        for attachment in self.attached_geoms:
            sheetmetal_description += f'position(attachment["anchorname"]) {attachment["geom"].get_base_descriptor()};\n'
        return sheetmetal_description
    """
    propagate information to attached objects
    """
    def process(self):
        # pass anchor information on to any attaced geometries
        for attachment in self.attached_geoms:
            attachment["geom"].give_attach_info(self.anchors[attachment["anchorname"]])
            attachment["geom"].process()
        
class SheetMetalBendableObj(SheetMetalObj):
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
            "orient":orient,
            "anchor":anchor
        }
        super().__init__(includes=["rosetta-stone/sheet-metal.scad"], module_name="sheetmetal_bend")
        self.anchors = dict()
        self.process()
    def bend(self, bend=True):
        self.config["bend"] = bend
        # re-calculate anchor information and propagate
        self.process()
    def process(self):
        # todo make these relative to their anchor and orientation (possibly only related to orientation of the anchored_to point)
        if self.config["bend"]:
            bent_size = [2*(self.config["ir"]+self.config["metal_thickness"]),self.config["edge_len"],2*(self.config["ir"]+self.config["metal_thickness"])];
            bent_attach1_loc = polar_to_cart(self.config["ir"]+self.config["metal_thickness"]/2, 0);
            bent_attach1_loc3d_translated = [
                bent_attach1_loc[0] + self.translation[0],
                self.translation[1],
                bent_attach1_loc[1] + self.translation[2]]
            bent_attach1_dir = DOWN
            bent_attach2_loc = polar_to_cart(self.config["ir"]+self.config["metal_thickness"]/2, self.config["ang"]);
            bent_attach2_loc3d_translated = [
                bent_attach2_loc[0] + self.translation[0],
                self.translation[1],
                bent_attach2_loc[1], + self.translation[2]]
            bent_attach2_dir = polar_to_cart(1, self.config["ang"]+90);
            self.anchors["attach1"] = {
                "anchor":bent_attach1_loc3d_translated,
                "orient":bent_attach1_dir}
            self.anchors["attach2"] = {
                "anchor":bent_attach2_loc3d_translated,
                "orient":bent_attach2_dir}
        else:
            unbent_size = [2*pi*self.config["ir"]*self.config["ang"]/360, self.config["edge_len"], self.config["metal_thickness"]];
            self.anchors["attach1"] = {
                "anchor":[-unbent_size[0]/2, 0, 0],
                "orient":LEFT}
            self.anchors["attach2"] = {
                "anchor":[unbent_size[0]/2, 0, 0],
                "orient":RIGHT}
        # unbent_size = [2*pi*self.config["ir"]*self.config["ang"]/360, self.config["edge_len"], self.config["metal_thickness"]];
        # unbent_attach1_loc = [self.config["ir"] + self.config["metal_thickness"]/2 if self.config["bend"] else self.unbent_size[0]/2, 0, 0]
        # self.attach2_loc = polar_to_cart(self.config["ir"]+self.config["metal_thickness"]/2, self.config["ang"]);
        # self.bent_attach1_loc = polar_to_cart(self.config["ir"]+self.config["metal_thickness"]/2, 0);
        # self.bent_attach2_dir = polar_to_cart(1, self.config["ang"]+90);

        super().process()

