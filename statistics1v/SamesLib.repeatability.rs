//345678901234567890123456789012345678901234567890123456789012345678901234567890
// WPMS2023.naive.rs

use regex::Regex;

//345678901234567890123456789012345678901234567890123456789012345678901234567890

pub fn is_a_num_str(str_a: &str) -> bool {
    let sstr = str_a.trim();
    let re = Regex::new(r"^\d$").unwrap();
    if re.is_match(sstr) {
        return true;
    }
    return false;
}

pub fn is_whitespace_only(str_a: &str) -> bool {
    let sstr = str_a.trim();
    if sstr.len() > 0 {
        return false;
    }
    return true;
}

pub fn is_usable_number_vector(v_a: &[&str]) -> bool {
    for element in v_a.iter() {
        if is_a_num_str(element) {
            continue;
        }
        return false;
    }
    return true;
}

pub fn round_to_f64_precision(subject_float: f64, precision_digits: usize) -> f64 {
    let base: f64 = 10.0;
    let precision_base: f64 = base.powf( precision_digits as f64 );
    let buffer: f64 = ( subject_float * precision_base ).round();
    let newfloat: f64 = buffer / precision_base;
    return newfloat;
}

pub trait VectorOfX {
 //   fn flail_unused_field(&self) -> (usize, bool);
    fn gen_count(&self) -> usize;
    fn new(vector_of_x: Vec<&str>) -> Self;
    fn push_x_string(&mut self,x: &str);
}

pub struct VectorOfContinuous {
    in_precision: usize,
    out_precision: usize,
    use_sum_of_xs: bool,
    vector_of_x: Vec<f64>,
}

impl Default for VectorOfContinuous {
    fn default() -> Self {
        VectorOfContinuous {
            in_precision: 4,
            out_precision: 4,
            use_sum_of_xs: false,
            vector_of_x: Vec::new(),
        }
    }
}

impl VectorOfX for VectorOfContinuous {

/*
    fn flail_unused_field(&self) -> (usize, bool) {
        return ( self.out_precision, self.use_sum_of_xs );
    }
 */

    fn gen_count(&self) -> usize {
        let n = self.vector_of_x.len();
        return n;
    }

    fn new(vector_of_x: Vec<&str>) -> Self {
        let mut buffer: VectorOfContinuous = Default::default();
        for lx in vector_of_x.iter() {
            buffer.push_x_string(lx);
        }
        return buffer;
    }

    fn push_x_string(&mut self, x_string: &str) {
        let x_float_unrounded: f64  = x_string.trim().parse().expect("push_x_string parse failure.");
        let x_float                 = round_to_f64_precision(x_float_unrounded, self.in_precision);
        self.vector_of_x.push(x_float);
    }

}

impl VectorOfContinuous {

    pub fn gen_sum(&self) -> f64 {
        let sumxs = self.vector_of_x.iter().sum();
        return sumxs;
    }

    pub fn gen_mean(&self) -> f64 {
        let n               = self.gen_count();
        let sumxs           = self.gen_sum();
        let mu_unrounded    = sumxs  / ( n as f64 );
        let mu              = round_to_f64_precision(mu_unrounded, self.out_precision);
        return mu;
    }

    pub fn gen_meanstddev(&self) -> f64 {
        let variance;
        if self.use_sum_of_xs {
            variance = self.gen_variance_by_sum_of_xs_squared();
        } else {
            variance = self.gen_variance_by_sum_of_differences_from_mean();
        }
        let stddev = variance.sqrt();
        return stddev;
    }

    pub fn gen_variance_by_sum_of_differences_from_mean(&self) -> f64 {
        let mu                          = self.gen_mean();
        let n                           = self.gen_count();
        let mut sumofdiffsquared: f64   = 0.0;
        for lx in self.vector_of_x.iter() {
            let xlessmu                 = lx - mu;
            sumofdiffsquared            += xlessmu * xlessmu;
        }
        let divisor: f64                =  ( n - 1 ) as f64;
        let v                           = sumofdiffsquared / divisor;
        return v
    }

    pub fn gen_variance_by_sum_of_xs_squared(&self) -> f64 {
        let mu                      = self.gen_mean();
        let n                       = self.gen_count();
        let mut sumxssquared: f64   = 0.0;
        for lx in self.vector_of_x.iter() {
            sumxssquared            += lx * lx;
        }
        let numerator               = sumxssquared - ( mu * mu );
        let divisor: f64            =  ( n - 1 ) as f64;
        let v                       = numerator / divisor;
        return v
    }

    pub fn push_x(&mut self, x_float_unrounded: f64) {
        let x_float = round_to_f64_precision(x_float_unrounded, self.in_precision);
        self.vector_of_x.push(x_float);
    }

}

/*

*/
/*
struct VectorOfDiscrete {
    vector_of_x: Vec<String>;
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
                                # Subtract one here
                                # to get the offset.
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
        # This is broken.  Do NOT debug until later.  TBD
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
    # TBD for use with columns having discrete values.
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
*/

/*
#[cfg(test)]
/// > Run Tests?????? Could not tell first pass what the arrow character was.
mod tests {
}
 */

//345678901234567890123456789012345678901234567890123456789012345678901234567890
// End of WPMS2023.naive.rs
