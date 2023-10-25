from opynscad import WrappedObj, AttachableUnion
from dirs import *
from math import *

def vec_to_angle(vec):
    """ assume 2d for now
    """
    return atan2(vec[2], vec[0])*180/pi

def polar_to_cart(r, theta):
    return [r*cos(theta*pi/180), r*sin(theta*pi/180)]

def add_vec3d(vec1, vec2):
    return [vec1[0]+vec2[0], vec1[1]+vec2[1], vec1[2]+vec2[2]]

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
        super().__init__(includes=includes, uses=uses, module_name=module_name)
        self.anchors = dict()
        self.anchored_to = dict() # dictionary of what we are anchored to and the orientation (as given by the thing we are attached to)
        self.attached_geoms = []
    def collect_includes(self, includes):
        if len(self.attached_geoms) == 0:
            return self.includes
        for attached_geom in self.attached_geoms:
            for include in attached_geom["geom"].collect_includes(includes):
                if include not in includes:
                    includes.append(include)
        return includes
    def collect_uses(self, uses):
        if len(self.attached_geoms) == 0:
            return self.uses
        for attached_geom in self.attached_geoms:
            for use in attached_geom["geom"].collect_uses(uses):
                if use not in uses:
                    uses.append(include)
        return uses

    """
    attach something at a specific anchor point
    anchor is going to be an anchor and orientation
    """
    def attach(self, anchorname, geom):
        self.attached_geoms.append({"anchorname": anchorname, "geom": geom})
        geom.give_attach_info(self.anchors[anchorname])
        self.includes = self.collect_includes(self.includes)
        self.uses = self.collect_uses(self.uses)
    """
    give this bend information about it's anchor point
    anchor is a dict with key = anchorname
    and then location and orientation
    """
    def give_attach_info(self, anchorinfo):
        self.anchored_to = anchorinfo

    """ TODO: change this to use
        for each child object
        translate(anchored_to_global_coordinate)
        rot(from=anchor_to_orient, to=myanchor_orient)
        child_module(..., ..., anchor=myanchor)
        there will still possibly be some fudge rotations
        if that's the case calculate another side and see if that can be used to rotate the diff

        very important. they are also now not children. this should be a union of independent shapes
    """
    def get_sheetmetal_description(self):
        sheetmetal_description = self.get_base_description()
        if self.rotation != [0, 0, 0]:
            sheetmetal_description = f'rotate({self.rotation}) {sheetmetal_description}'
        if self.translation != [0, 0, 0]:
            sheetmetal_description = f'translate({self.translation}) {sheetmetal_description}'

        for attachment in self.attached_geoms:
            position=attachment["geom"].anchored_to["anchor"]
            if type(position) is str:
                position = f'"{position}"'
            anchor = attachment["geom"].config["anchor"]
            if type(anchor) is str:
                anchor = f'"{anchor}"'
            sheetmetal_description += f'attach({position}, {anchor}) {attachment["geom"].get_sheetmetal_description()};\n'
        return sheetmetal_description
    def get_descriptor(self):
        self.base_descriptor = self.get_sheetmetal_description()
        return super().get_descriptor()
        
    """
    propagate information to attached objects
    child process methods need to calculate their anchor positions in
    global coordinates using the positions they are anchored to and oriented to
    """
    def process(self):
        if len(self.anchored_to) != 0:
            self.process_angle()
        # pass anchor information on to any attaced geometries
        for attachment in self.attached_geoms:
            attachment["geom"].give_attach_info(self.anchors[attachment["anchorname"]])
            attachment["geom"].process()

""" just a non bent cube """
class SheetMetalNonBendable(SheetMetalObj):
    def __init__(
        self,
        size = [],
        spin = 0,
        orient = UP,
        anchor = CENTER):
        self.config = {
            "size": size,
            "spin":spin,
            "orient":orient,
            "anchor":anchor
        }
        super().__init__(includes=["BOSL2/std.scad"], module_name="cube")
        self.process()
    def process_angle(self):
        orient_angle = vec_to_angle(self.anchored_to["orient"])
        orient_angle += 90
        orient_vec2d = polar_to_cart(1, orient_angle)
        self.config["orient"] = [orient_vec2d[0], 0, orient_vec2d[1]]
        self.rotation = [90, 0, 0]
    
    def process(self):
        self.anchors["attach1"] = {"anchor": LEFT, "anchorloc": LEFT, "orient": LEFT}
        self.anchors["attach2"] = {"anchor": RIGHT, "anchorloc": RIGHT, "orient": RIGHT}
        super().process()

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
    def process_angle(self):
        orient_angle = vec_to_angle(self.anchored_to["orient"])
        if self.config["bend"]:
            orient_angle += 90
        else:
            orient_angle += 0
        orient_vec2d = polar_to_cart(1, orient_angle)
        self.config["orient"] = [orient_vec2d[0], 0, orient_vec2d[1]]
    def bend(self, bend=True):
        self.config["bend"] = bend
        # re-calculate anchor information and propagate
        self.process()
    def process(self):
        # todo make these relative to their anchor and orientation (possibly only related to orientation of the anchored_to point)
        # what we are anchored to and anchored
        try:
            anchored_to_loc = self.anchored_to["anchorloc"] # point on parent that we are anchored to
            anchored_to_orient = self.anchored_to["orient"] # point on parent that we are anchored to
        except:
            anchored_to_loc = [0, 0, 0] # assume center
            anchored_to_orient = [0, 0, 1] #assume up
        # should be attach1 attach2 or center
        # also assuming always that if we are attached to something our anchor is attach1
        # so really this should be center or attach1
        anchored_from = self.config["anchor"] # point on this obj that we are using as an anchor
        # if we aren't attached to anything and nothing is attached to us the anchor points dont really matter
        if self.config["bend"]:
            bent_size = [2*(self.config["ir"]+self.config["metal_thickness"]),self.config["edge_len"],2*(self.config["ir"]+self.config["metal_thickness"])];
            bent_attach1_loc2d = polar_to_cart(self.config["ir"]+self.config["metal_thickness"]/2, 0);
            bent_attach1_loc3d = [bent_attach1_loc[0], 0, bent_attach1_loc[1]]
            bent_attach1_loc3d_translated = add_vec3d(bent_attach1_loc3d, anchored_to_loc)
            bent_attach1_dir = DOWN
            bent_attach2_loc = polar_to_cart(self.config["ir"]+self.config["metal_thickness"]/2, self.config["ang"]);
            bent_attach2_loc3d = [bent_attach2_loc[0], 0, bent_attach2_loc[1]]
            bent_attach2_loc3d_translated = add_vec3d(bent_attach2_loc3d, anchored_to_loc)
            bent_attach2_dir = polar_to_cart(1, self.config["ang"]+90);
            self.anchors["attach1"] = {
                "anchor": "attach1",
                "anchorloc":bent_attach1_loc3d_translated,
                "orient":bent_attach1_dir}
            self.anchors["attach2"] = {
                "anchor": "attach2",
                "anchorloc":bent_attach2_loc3d_translated,
                "orient":[bent_attach2_dir[0], 0, bent_attach2_dir[1]]}
        else:
            unbent_size = [2*pi*self.config["ir"]*self.config["ang"]/360, self.config["edge_len"], self.config["metal_thickness"]];
            self.anchors["attach1"] = {
                "anchor": LEFT, # relative to the object
                "anchorloc": anchored_to_loc, # global coordinates
                "orient":LEFT}
            self.anchors["attach2"] = {
                "anchor": RIGHT,
                "anchorloc": [anchored_to_loc[0] + unbent_size[0], anchored_to_loc[1], anchored_to_loc[2]],
                "orient":RIGHT}
        # unbent_size = [2*pi*self.config["ir"]*self.config["ang"]/360, self.config["edge_len"], self.config["metal_thickness"]];
        # unbent_attach1_loc = [self.config["ir"] + self.config["metal_thickness"]/2 if self.config["bend"] else self.unbent_size[0]/2, 0, 0]
        # self.attach2_loc = polar_to_cart(self.config["ir"]+self.config["metal_thickness"]/2, self.config["ang"]);
        # self.bent_attach1_loc = polar_to_cart(self.config["ir"]+self.config["metal_thickness"]/2, 0);
        # self.bent_attach2_dir = polar_to_cart(1, self.config["ang"]+90);

        super().process()

