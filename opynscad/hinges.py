# import pdb
# pdb.set_trace()
from .opynscad import OpynScadWriter, WrappedObj
from .dirs import *

class HingeFin(WrappedObj):
    def __init__(
        self,
        angle_per_fin,
        cut_depth,
        height_of_cut,
        top_length_of_fin,
        minimum_gap,
        fudge_factor = 0.001,
        spin = 0,
        orient = UP,
        anchor = CENTER):
        self.config = {
            "angle_per_fin":angle_per_fin,
            "cut_depth":cut_depth,
            "height_of_cut":height_of_cut,
            "top_length_of_fin":top_length_of_fin,
            "minimum_gap":minimum_gap,
            "fudge_factor":fudge_factor,
            "spin":spin,
            "orient":orient,
            "anchor":CENTER
        }
        super().__init__(includes=["rosetta-stone/hinges.scad"], module_name="hinge_fin")
    def process(self):
        # extra processing not necessary
        pass

# @dataclass
# class HingeProfileConfig:
#     # inner_radius,
#     bend_range: float
#     span_of_hinge: float
#     height_of_material_cut: float # height of the material being cut
#     cut_depth: float
#     number_of_fins: int
#     layer_height: float=0.2
#     layers_to_bend: int=2
#     minimum_gap: float=0.5
#     # minimum_straight=0.5,
#     fudge_factor: float=0.001
#     spin: float=0
#     orient: List = field(default_factory=lambda: UP)
#     anchor: List = field(default_factory=lambda: CENTER)
