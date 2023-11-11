
    def generateMeanAbsoluteError
# Should be 2v:
#https://en.wikipedia.org/wiki/Mean_absolute_error
        amean                   = calculateArithmeticMean
        nf                      = @VectorOfX.size.to_f
        sumofabsolutediffs      = 0
        @VectorOfX.each do |lx|
            previous            = sumofabsolutediffs
            sumofabsolutediffs  += ( lx - amean ).abs
            if previous > sumofabsolutediffs then
                # These need review.  
                raise RangeError, "previous #{previous} > sumofdiffssquared #{sumofabsolutediffs}"
            end
        end
        unrounded                     = sumofabsolutediffs / nf
        rounded = unrounded.round(@OutputDecimalPrecision)
        return rounded
    end

