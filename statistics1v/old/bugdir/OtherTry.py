#!/usr/bin/python3

class Try:

    def __init__(self,xa=[]):
        self.XA = xa

    def getCount(self):
        l = len(self.XA)
        return l

    @classmethod
    def newAfter(cls,arrayA):
        localo = cls()
        localo.pushX(arrayA[0])
        return localo

    def pushX(self,xFloat):
        self.XA.append(xFloat)

    def pushXold(self,xFloat):
        lfn = float(xFloat)
        lrn = round(lfn,4)
        self.XA.append(lrn)

