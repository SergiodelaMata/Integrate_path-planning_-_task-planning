import sys

class add_path():
    '''
        Wrapper class to automatically handle adding the local controller
        directory to the simulator's execution path.
    '''
    def __init__(self, path):
        self.path = path

    def __enter__(self):
        sys.path.insert(0, self.path)

    def __exit__(self, exc_type, exc_value, traceback):
        try:
            sys.path.remove(self.path)
        except ValueError:
            pass

def load_controller(name):
    with add_path('controllers'):
        components = name.split('.')
        controller = __import__(components[0])
        for comp in components[1:]:
            controller = getattr(controller, comp)
    return controller
