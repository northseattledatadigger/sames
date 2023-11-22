class Try:

    def __init__(self,xa=[]):
        self.XA = xa

    def getCount(self):
        return len(self.XA)

    @classmethod
    def newAfter(cls,arrayA):
        localo = cls()
        localo.pushX(arrayA[0])
        return localo

    def pushX(self,xFloat):
        self.XA.append(xFloat)
