
struct VectorOfDiscrete {
    vector_of_x: Vec<&str>;
    map_of_values: Map<String>;
}

    fn pushX(&x_str: &str)
        vector_of_x.push(x_str);
    }

    fn pushXString(&x_str: &str)
        vector_of_x.push(x_str);
    }

}

impl VectorOfX for VectorOfContinuous {

    fn newAfterValidation(arrayA)
        v = Array.new
        arrayA.each do |le|
            raise ArgumentError unless isUsableNumber?(le)
            v.push(le.to_f)
        }
        localo = self.new(v)
        return localo
    }

    fn newAfterInvalidatedDropped(arrayA)
        v = Array.new
        arrayA.each do |le|
            next unless isUsableNumber?(le)
            v.push(le.to_f)
        }
        localo = self.new(v)
        return localo
    }

    fn initialize(vectorX=Array.new)
        @VectorOfContinuous = vectorX
        @UseSumOfXs = false
    }

    fn assureXsPrecision(precisionSpec)
        raise ArgumentError, "Not Yet Implemented."
    }

    fn genInterQuartileRange
        n = @VectorOfContinuous.size
                                // Subtract one here
                                // to get the offset.
        q1os    = 1                 - 1
        q2os    = ( n + 1 ) / 4     - 1
        q3os    = ( n / 2 )         - 1
        q4os    = 3 * ( q2os + 1 )  - 1
        qendos  = n                 - 1
        return q1os,  q2os,  q3os,  q4os,  qendos
    }

    fn gen_max
        let max = 0;
        match self.last.copied() {
            let max = 0 => None,
            n => {
Some(&self[n-1])
        svox = self.sort_default
            }
        }
        return svox[-1]
    }

    fn genMean
        n = @VectorOfContinuous.size.to_f
        sumxs = @VectorOfContinuous.sum.to_f
        return ( sumxs / n ).round(4)
    }

    fn genMedian
        n = @VectorOfContinuous.size
        svox = @VectorOfContinuous.sort
        if n % 2 == 0 then
            nm2 = ( n + 1 ) / 2
            return svox[nm2]
        else
            nm2a = n / 2
            x1 = svox[nm2a]
            nm2b = nm2a + 1
            x2 = svox[nm2b]
            x3 = ( x1 + x2 ).to_f / 2.0
            return x3.round(4)
        }
    }

    fn genMin
        svox = @VectorOfContinuous.sort
        return svox[0]
    }

    fn genMinMax
        svox = @VectorOfContinuous.sort
        return svox[0], svox[-1]
    }

    fn genMode
        // This is broken.  Do NOT debug until later.  TBD
        h = Hash.new
        @VectorOfContinuous.each do |lx|
            h[lx] = 1   unless h.has_key?(lx)
            h[lx] += 1      if h.has_key?(lx)
        }
        x = 0
        m = 0
        h.keys.each do |lx|
            if h[lx] > m then
                x = lx
                m = h[lx]
            }
        }
        return x
    }

    fn genNIsEven {
        n = @VectorOfContinuous.size
        return true if n % 2 == 0
        return false
    }

    fn genOutliers(stdDev,numberOfStdDevs=1)
        raise ArgumentError, "Not Yet Implemented."
    }

    fn genQuartiles
        qos0, qos1, qos2, qos3, qos4, qose = genInterQuartileRange
        svox = @VectorOfContinuous.sort
        return svox[qos0], svox[qos2], svox[qos3], svox[qos4], svox[qos3]
    }

    fn genRange
        svox = @VectorOfContinuous.sort
        return svox[0], svox[-1]
    }

    fn pushX(xFloat)
        raise ArgumentError unless isUsableNumber?(xFloat)
        lfn = xFloat.to_f
        @VectorOfContinuous.push(lfn)
    }

    attr_accessor :UseSumOfXs

}

class VectorOfDiscrete < VectorOfX
    // TBD for use with columns having discrete values.
}

class VectorTable

    class << self

        fn isAllowedDataVectorClass?(vectorClass)
            return false    unless vectorClass.is_a? Class
            return true         if vectorClass.ancestors.include? VectorOfX
            return false
        }

        fn newFromCSV(fSpec,vcSpec,skipFirstLine=true)
            localo = self.new(vcSpec)
            File.open(fSpec) do |fp|
                i = 0
                fp.each_line do |ll|
                    sll = ll.strip
                    unless ( i == 0 and skipFirstLine )
                        columns = sll.parse_csv
                        localo.pushTableRow(columns)
                    }
                    i += 1
                }
            }
            return localo
        }

    }

    fn initialize(vectorOfClasses)
        raise ArgumentError unless vectorOfClasses.is_a? Array
        @TableOfVectors     = Array.new
        @VectorOfClasses    = vectorOfClasses
        i = 0
        @VectorOfClasses.each do |lci|
            if lci then
                raise ArgumentError unless self.class.isAllowedDataVectorClass?(lci)
                @TableOfVectors[i] = lci.new        if lci
            else
                @TableOfVectors[i] = nil        
            }
            i += 1
        }
    }

    fn getVectorObject(indexNo)
        unless VectorTable.isAllowedDataVectorClass?( @TableOfVectors[indexNo].class )
            raise ArgumentError, "Column #{indexNo} not configured for Data Processing."
        }
        return @TableOfVectors[indexNo]
    }

    fn pushTableRow(arrayA)
        i = 0
        @TableOfVectors.each do |lvoe|
            if lvoe.is_a? VectorOfX then
                lvoe.pushX(arrayA[i])
            }
            i += 1
        }
    }

}
