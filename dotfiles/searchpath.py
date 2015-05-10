import os
import sys

#-------------------------------------------------------------------------------

def _normalize(item):
    return os.path.abspath(str(item))


class SearchPath:
    """
    A search path, ala `PATH` and `CLASSPATH`, of colon-separated strings.
    """

    SEP = ":"

    def __init__(self, items):
        self.__items = [ i for i in items if len(i) > 0 ]


    @classmethod
    def split(class_, *items):
        return class_(sum(( i.split(class_.SEP) for i in items ), []))


    @classmethod
    def env(class_, name):
        return class_.split(os.environ[name])


    def __repr__(self):
        return "{}({})".format(
            self.__class__.__name__, 
            ", ".join( repr(p) for p in self.__items ))


    def __str__(self):
        return self.SEP.join(self.__items)


    def __iter__(self):
        return iter(self.__items)


    def __len__(self):
        return len(self.__items)


    def __getitem__(self, index):
        return self.__items[index]


    def remove(self, item):
        item = _normalize(item)
        self.__items = [ i for i in self.__items if i != item ]
        return self


    def __truediv__(self, item):
        return self.remove(item)


    def prepend(self, item):
        """
        Prepends `item`, after removing any existing instances.
        """
        item = _normalize(item)
        self.remove(item)
        self.__items.insert(0, item)
        return self


    def __rshift__(self, item):
        """
        Synonynm for `prepend()`.
        """
        return self.prepend(item)


    def append(self, item):
        """
        Appends `item`, after removing any existing instances.
        """
        item = _normalize(item)
        self.remove(item)
        self.__items.append(item)
        return self


    def __lshift__(self, item):
        """
        Synonynm for `append()`.
        """
        return self.append(item)



#-------------------------------------------------------------------------------

def main(argv):
    def error(message):
        print >> sys.stderr, message
        raise SystemExit(2)

    argv = list(argv)
    prog = argv.pop(0)
    searchpath = SearchPath.split(argv.pop(0))
    while len(argv) > 0:
        operation = argv.pop(0)
        try:
            argument = argv.pop(0)
        except IndexError:
            error("no argument for {}".format(operation))
        else:
            if operation in ("remove", "rm"):
                searchpath = searchpath.remove(argument)
            elif operation in ("prepend", "pre"):
                searchpath = searchpath.prepend(argument)
            elif operation in ("append", "app"):
                searchpath = searchpath.append(argument)
            else:
                error("unknown operation {}".format(operation))
    print searchpath


if __name__ == "__main__":
    main(sys.argv)


