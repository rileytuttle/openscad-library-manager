class ScadObj:
    def __init__(self, includes=[], uses=[]):
        self.includes = includes
        self.uses = uses
        self.translation = [0, 0, 0]
        self.rotation = [0, 0, 0]
    def translate(self, translation):
        for axis, val in enumerate(translation):
            self.translation[axis] += val
        self.process()
    def rotate(self, rotation):
        for axis, val in enumerate(rotation):
            self.rotation[axis] += val
        self.process()
    def get_includes(self):
        return self.includes
    def get_uses(self):
        return self.uses
    def get_descriptor(self):
        descriptor = f'translate({self.translation}) rotate({self.rotation}) ' + self.base_descriptor
        return descriptor
    def process(self):
        pass

class RawScadObj(ScadObj):
    def __init__(self, rawscad, includes=[], uses=[]):
        self.base_descriptor = rawscad
        super().__init__(includes, uses)

class CombGeometry(ScadObj):
    def __init__(self, geoms=[]):
        self.geoms = geoms
        super().__init__()
        self.collect_incs(geoms)
        self.collect_uses(geoms)
    def collect_incs(self, geoms):
        if type(geoms) is not list and type(geoms) is not None:
            for inc in geoms.includes:
                if inc not in self.includes:
                    self.includes.append(inc)
        else:
            for geom in geoms:
                self.collect_incs(geom)
    def collect_uses(self, geoms):
        if type(geoms) is not list and type(geoms) is not None:
            for use in geoms.uses:
                if use not in self.uses:
                    self.uses.append(use)
        else:
            for geom in geoms:
                self.collect_uses(geom)

class AttachableGeom(CombGeometry):
    def __init__(self, base_geom):
        self.base_geom = base_geom
        self.positions = []
        self.base_descriptor = f'{base_geom.get_descriptor()};'
        self.anchors = dict()
        super().__init__(base_geom)
    def get_anchors(self):
        return self.anchors
    def position(self, anchor, geom):
        self.positions.append([anchor, geom])
        self.get_base_descriptor()
        self.collect_incs(geom)
        self.collect_uses(geom)

class AttachableUnion(AttachableGeom):
    def __init__(self, base_geom):
        super().__init__(base_geom)
    def get_base_descriptor(self):
        descriptor = self.base_geom.get_descriptor()
        descriptor += ' {\n' 
        for position, geom in self.positions:
            descriptor += f'position({position}) {geom.get_descriptor()};\n'
        descriptor += "}\n"
        self.base_descriptor = descriptor

class Union(CombGeometry):
    def __init__(self, geoms):
        self.base_descriptor = self.union(geoms)
        super().__init__(geoms)
    def union(self, geoms):
        command = "union() {\n\n"
        for geom in geoms:
            command += f'{geom.get_descriptor()};\n\n'
        command += "}" 
        return command

class Difference(CombGeometry):
    def __init__(self, geoms):
        self.base_descriptor = self.difference(geoms)
        super().__init__(geoms)
    def difference(self, geoms):
        command = "difference() {\n\n"
        for geom in geoms:
            command += f'{geom.get_descriptor()};\n\n'
        command += "}" 
        return command

class OpynScadWriter:
    def __init__(self, filepath):
        self.path = filepath
        self.customizations = []
    def set_customizations(self, customizations):
        self.customizations=customizations
    def write(self, geom):
        with open(self.path, 'w+') as filehandle:
            for inc in geom.get_includes():
                filehandle.write(f'include <{inc}>\n')
            for use in geom.get_uses():
                filehandle.write(f'use <{use}>\n')
            filehandle.write('\n')
            for key, val in self.customizations:
                filehandle.write(f'{key} = {val}\n')
            filehandle.write('\n')
            filehandle.write(geom.get_descriptor())

# a simple wrapper around an already written openscad module
class WrappedObj(ScadObj):
    def __init__(self, module_name, includes=[], uses=[]):
        self.module_name=module_name
        self.base_descriptor = self.get_base_description()
        super().__init__(includes, uses)
    def process(self):
        pass
    def get_base_description(self):
        command = f'{self.module_name}('
        for key, value in self.config.items():
            if type(value) is bool:
                value = "true" if value else "false"
            elif type(value) is str:
                value = f'"{value}"'
            next_piece = f'\n{key}={value},'
            # print(next_piece)
            command += next_piece
        if command[-1] == ",":
            command = command[:-1]
        command += ")"
        return command
