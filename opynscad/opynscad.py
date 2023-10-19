class Geometry:
    def __init__(self, includes=[],uses=[]):
        self.unions = []
        self.differences = []
        self.intersections = []
        self.includes = includes
        self.uses = uses
        self.translation = []
        self.rotation = []
    def translate(self, translation):
        # self.translation += translation
        self.descriptor = f'translate({translation}) ' + self.descriptor
    def rotate(self, rotation):
        self.descriptor = f'rotate({rotation}) ' + self.descriptor
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
    def raw_scad(self, raw_scad):
        self.descriptor = raw_scad
    def write(self):
        return self.descriptor

class UnionObj(Geometry):
    def __init__(self, objlist):
        super().__init__()
        self.collect_incs(objlist)
        self.collect_uses(objlist)
        self.descriptor = self.union(objlist)
    def union(self, objlist):
        command = "union() {\n\n"
        for obj in objlist:
            command += f'{obj.write()};\n\n'
        command += "}" 
        return command

class DiffObj(Geometry):
    def __init__(self, objlist):
        super().__init__()
        self.collect_incs(objlist)
        self.collect_uses(objlist)
        self.descriptor = self.diff(objlist)
    def diff(self, objlist):
        command = "difference() {\n\n"
        for obj in objlist:
            command += f'{obj.write()};\n\n'
        command += "}" 
        return command

class OpynScadWriter:
    def __init__(self, filepath):
        self.path = filepath
    def write(self, geom):
        with open(self.path, 'w+') as filehandle:
            for inc in geom.get_includes():
                filehandle.write(f'include <{inc}>\n')
            for use in geom.get_uses():
                filehandle.write(f'use <{use}>\n')
            filehandle.write('\n')
            filehandle.write(geom.get_descriptor())

class ScadObj:
    def __init__(self, includes=[], uses=[]):
        self.includes = includes
        self.uses = uses
        self.translation = [0, 0, 0]
        self.rotation = [0, 0, 0]
    def translate(self, translation):
        self.translation += translation
        self.process()
    def rotate(self, uses):
        self.uses += uses
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

class OpynScadObj(ScadObj):
    def __init__(self):
        pass

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
            command += f'\n{key}={value},'
        if command[-1] == ",":
            command = command[:-1]
        command += ")"
        return command
    def translate(self, translation):
        self.descriptor = f'translate({translation}) ' + self.descriptor
        self.translation += translation
        self.process()
    def rotate(self, rotation):
        self.descriptor = f'rotate({rotation}) ' + self.descriptor
        self.rotation += rotation
        self.process()
