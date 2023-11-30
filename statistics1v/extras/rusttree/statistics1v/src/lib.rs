//345678901234567890123456789012345678901234567890123456789012345678901234567890
// WPMS2023.naive.rs

use regex::Regex;
use std::collections::*;
//use std::{error::Error, fmt};
//use std::process::{ExitCode, Termination};
use thiserror::Error;
//use std::collections::HashMap;

//345678901234567890123456789012345678901234567890123456789012345678901234567890
// Validation Errors

// This is partly stolen from:  https://kerkour.com/rust-error-handling
#[derive(thiserror::Error, Debug, Clone)]
pub enum ValidationError {
    #[error("String number exceeds float capacity")]
    FloatCapacityExceeded,
    #[error("Index out of bounds")]
    RangeError,
    #[error("Permission Denied.")]
    PermissionDenied,
    #[error("Invalid argument: {0}")]
    InvalidArgument(String),
}
/*
 */

//345678901234567890123456789012345678901234567890123456789012345678901234567890
// Global Procedures

pub fn generate_mode_from_frequency_aa<'a>(faa_a: &'a HashMap<&'a str, u32>) -> &'a str {
    let mut x = "";
    let mut m = 0;
    for (key, &value) in faa_a.iter() {
        if value > m {
            x = key;
            m = value;
        }
    }
    return x;
}

pub fn is_a_num_str(str_a: &str) -> bool {
    let sstr = str_a.trim();
    let re = Regex::new(r"^-?\d*\.?\d+$").unwrap();
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

pub fn is_usable_number_string_array(a_a: &[&str]) -> bool {
    for element in a_a.iter() {
        if is_a_num_str(element) {
            continue;
        }
        return false;
    }
    return true;
}

pub fn is_usable_number_string_vector(v_a: &Vec<&str>) -> bool {
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

//345678901234567890123456789012345678901234567890123456789012345678901234567890
//345678901234567890123456789012345678901234567890123456789012345678901234567890
// HistogramOfX and RangeOccurrence
// NOTE:  Because Python3, unlike Ruby, is such a hodgepodge of inconsistent
// constructs and confusing extra decorations, I decided to pull RangeOccurrence
// out into indepencent space instead of having it as a nested class, for the
// Python3 version.  This makes it simpler and clearer, and I will need to do
// similar things in other non-class oriented languages anyway.

pub trait RangeAccess {
    fn add_to_count(&mut self);
    fn has_overlap(&self,start_no: f64, stop_no: f64) -> bool;
    fn is_in_range(&self, x_float: f64) -> bool;
    fn new(start_no: f64, stop_no: f64) -> Self;
}

pub struct RangeOccurrence {
    count: usize,
    start_no: f64,
    stop_no: f64,
}

impl Default for RangeOccurrence {
    fn default() -> Self {
        RangeOccurrence {
            count: 0,
            start_no: 0.0,
            stop_no: 0.0,
        }
    }
}

impl RangeAccess for RangeOccurrence {

    fn add_to_count(&mut self) {
        self.count += 1;
    }

    fn has_overlap(&self,start_no: f64, stop_no: f64) -> bool {
        if ( self.start_no <= start_no ) && ( start_no < self.stop_no ) {
            return true;
        }
        if ( self.start_no < stop_no ) && ( stop_no <= self.stop_no ) {
            return true;
        }
        return false;
    }

    fn is_in_range(&self, x_float: f64) -> bool {
        if x_float < self.start_no {
            return false;
        }
        if self.stop_no <= x_float {
            return false;
        }
        return true;
    }

    fn new(start_no: f64, stop_no: f64) -> Self {
        let mut buffer: RangeOccurrence = Default::default();
        buffer.start_no = start_no;
        buffer.stop_no = stop_no;
        return buffer;
    }

}

pub trait HistogramMethods {
    fn add_to_counts(&mut self, x_float: f64);
    fn generate_count_collection(&self) -> Vec<f64>;
    fn is_in_range(&self, x_float: f64) -> bool;
    fn new(lowest_value: f64, highest_value: f64) -> Self;
    fn validate_no_overlap(&self,start_no: f64, stop_no: f64) -> Result<(), ValidationError>;
    //fn new_from_desired_segment_count(cls,startNo,maxNo,desiredSegmentCount,extraMargin=None):
    //fn new_from_uniform_segment_size(cls,startNo,maxNo,segmentSize):
    fn set_occurrence_range(&self,start_no: f64,stop_no: f64);
    fn validate_ranges_complete(&self) -> Result<(), ValidationError>;
}

pub struct HistogramOfX {
        //self.FrequencyAA[startNo] = RangeOccurrence(startNo,stopNo)
    frequency__aa:  HashMap<f16, RangeOccurrence>;
    max: f64,
    min: f64,
}

impl Default for HistogramOfX {
    fn default() -> Self {
        HistogramOfX {
            frequency__aa:  (),
            max: 0.0,
            min: 0.0,
        }
    }
}

impl HistogramMethods for HistogramOfX {

    fn new(lowest_value: f64, highest_value: f64) -> Self {
        let mut buffer: HistogramOfX = Default::default();
        buffer.max              = highest_value;
        buffer.min              = lowest_value;
        return buffer;
    }

}

/*
#[derive(Debug, Snafu)]
enum MyError {
    #[snafu(display("Refrob the Gizmo"))]
    Gizmo,
    #[snafu(display("The widget '{widget_name}' could not be found"))]
    WidgetNotFound { widget_name: String },
}

fn foo() -> Result<(), MyError> {
    WidgetNotFoundSnafu {
        widget_name: "Quux",
    }
    .fail()
}

fn main() {
    if let Err(e) = foo() {
        println!("{}", e);
        // The widget 'Quux' could not be found
    }
}


class HistogramOfX:

    def __init__(self,lowestValue,highestValue):
        if ( not isinstance(lowestValue,numbers.Number) ):
            raise ValueError(f"lowestValue argument '{lowestValue}' is not a number.")
        if ( not isinstance(highestValue,numbers.Number) ):
            raise ValueError(f"highestValue argument '{highestValue}' is not a number.")
        self.FrequencyAA    = {}
        self.Max            = highestValue
        self.Min            = lowestValue

    def _validateNoOverlap(self,startNo,stopNo):
        if ( not isinstance(startNo,numbers.Number) ):
            raise ValueError(f"startNo argument '{startNo}' is not a number.")
        if ( not isinstance(stopNo,numbers.Number) ):
            raise ValueError(f"stopNo argument '{stopNo}' is not a number.")
        for lroo in self.FrequencyAA.values():
            if lroo.hasOverlap(startNo,stopNo):
                m = f"Range [{startNo},{stopNo}] overlaps with another range:  [{lroo.StartNo},{lroo.StopNo}]."
                raise ValueError(m)

    def addToCounts(self,xFloat):
        if ( not isinstance(xFloat,numbers.Number) ):
            raise ValueError(f"xFloat argument '{xFloat}' is not a number.")
        for lstartno in sorted(self.FrequencyAA):
            lroo = self.FrequencyAA[lstartno]
            if xFloat < lroo.StopNo:
                lroo.addToCount()
                return
        m = "Programmer Error:  "
        m += f"No Frequency range found for xFloat:  '{xFloat}'."
        raise ValueError( m )

    def generateCountCollection(self):
        orderedlist = []
        for lstartno in sorted(self.FrequencyAA):
            lroo = self.FrequencyAA[lstartno]
            orderedlist.append([lstartno,lroo.StopNo,lroo.Count])
        return orderedlist

    @classmethod
    def newFromDesiredSegmentCount(cls,startNo,maxNo,desiredSegmentCount,extraMargin=None):
        if extraMargin is None:
            extraMargin = 0
        if ( not isinstance(startNo,numbers.Number) ):
            raise ValueError(f"startNo argument '{startNo}' is not a number.")
        if ( not isinstance(maxNo,numbers.Number) ):
            raise ValueError(f"maxNo argument '{maxNo}' is not a number.")
        if ( type(desiredSegmentCount) != int ):
            raise ValueError(f"desiredSegmentCount argument '{desiredSegmentCount}' is not an integer.")
        if ( not isinstance(extraMargin,numbers.Number) ):
            raise ValueError(f"extraMargin argument '{extraMargin}' is not a number.")
        # xc 20231106:  Don't worry about cost of passing the AA around until efficiency passes later.
        totalbreadth    = float( maxNo - startNo + 1 + extraMargin )
        dscf            = float(desiredSegmentCount)
        segmentsize     = totalbreadth / dscf
        localo          = cls.newFromUniformSegmentSize(startNo,maxNo,segmentsize)
        return localo

    @classmethod
    def newFromUniformSegmentSize(cls,startNo,maxNo,segmentSize):
        if ( not isinstance(startNo,numbers.Number) ):
            raise ValueError(f"startNo argument '{startNo}' is not a number.")
        if ( not isinstance(maxNo,numbers.Number) ):
            raise ValueError(f"maxNo argument '{maxNo}' is not a number.")
        if ( not isinstance(segmentSize,numbers.Number) ):
            raise ValueError(f"segmentSize argument '{segmentSize}' is not a number.")
        # xc 20231106:  Don't worry about cost of passing the AA around until efficiency passes later.
        localo          = HistogramOfX(startNo,maxNo)
        bottomno        = startNo
        topno           = bottomno + segmentSize
        while bottomno <= maxNo:
            localo.setOccurrenceRange(bottomno,topno)
            bottomno    = topno
            topno       += segmentSize
        return localo

    def setOccurrenceRange(self,startNo,stopNo):
        if ( not isinstance(startNo,numbers.Number) ):
            raise ValueError(f"startNo argument '{startNo}' is not a number.")
        if ( not isinstance(stopNo,numbers.Number) ):
            raise ValueError(f"stopNo argument '{stopNo}' is not a number.")
        if stopNo <= startNo:
            raise ValueError(f"stopNo must be larger than startNo.")
        self._validateNoOverlap(startNo,stopNo)
        self.FrequencyAA[startNo] = RangeOccurrence(startNo,stopNo)

    fn validateRangesComplete(&self) -> Result<(), ValidationError> {
        i = 0
        lroo = None
        previous_lroo = None
        for lstartno in sorted(self.FrequencyAA):
            lroo = self.FrequencyAA[lstartno]
            if lstartno != lroo.StartNo:
                raise IndexError( "Programmer Error on startno assignments." )
            if i == 0:
                if lroo.StartNo > self.Min:# NOTE:  Start may be before the minimum,
                                           # but NOT after it, as minimum value must
                                           # be included in the first segment.
                    m = f"Range [{lroo.StartNo},{lroo.StopNo}] "
                    m += f" starts after the minimum designated value '{self.Min}."
                    raise IndexError( m )
            else:
                if lroo.StartNo != previous_lroo.StopNo:
                    m = f"Range [{previous_lroo.StartNo},{previous_lroo.StopNo}]"
                    m += " is not adjacent to the next range "
                    m += f"[{lroo.StartNo},{lroo.StopNo}]."
                    raise IndexError( m )
            i += 1
            previous_lroo = lroo

        if self.Max > lroo.StopNo:
            m = f"Range [{lroo.StartNo},{lroo.StopNo}] "
            m += f" ends before the maximum value '{self.Max}."
            raise IndexError( m )


enum BadDataAction {
    BlankField,
    DefaultFill,
    ExcludeRow,
    Fail,
    SkipRow,
    ZeroField,
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

#[cfg(test)]
mod tests {
/* NOTE:  this long tests stanza corresponds to the entirety of the
    test_SamesLib?simple.?? files for python and ruby.  Basic (simple)
    coverage of sanity checking use cases are attempted, and new use
    cases found in the others should be added to also, if they apply,
    here.
 */

    use std::collections::*;
    use super::*;

    // Global Procedures

    #[test]
    fn test_anecdote_expected_results() {
        let d: HashMap<&str, u32> = HashMap::from([("1234", 528), ("528", 3), ("A longer string", 0), ("x", 55555)]);
        let result = generate_mode_from_frequency_aa(&d);
        assert_eq!("x", result);
    }

    #[test]
    fn test_sees_number_strings() {
        assert!(is_a_num_str("1234"));
        assert!(is_a_num_str("1234.56789"));
        assert!(is_a_num_str(".1234"));
        assert!(is_a_num_str("1234.0"));
        assert!(!is_a_num_str("12 34"));
        assert!(!is_a_num_str("12x34"));
        assert!(!is_a_num_str("A"));
        assert!(!is_a_num_str("%"));
        assert!(!is_a_num_str(""));
    }

    #[test]
    fn test_is_whitespace_only() {
        assert!(is_whitespace_only(""));
        assert!(is_whitespace_only("    "));
        assert!(!is_whitespace_only("xxx"));
        assert!(!is_whitespace_only("1234"));
        assert!(!is_whitespace_only("0x32"));
    }

    #[test]
    fn test_is_usable_number_string_array() {
        assert!(is_usable_number_string_array(&["1","33.33","4"]));
        assert!(!is_usable_number_string_array(&["1"," 2 3 5 "]));
        assert!(!is_usable_number_string_array(&["1s","235"]));
        assert!(!is_usable_number_string_array(&[".","235"]));
        assert!(!is_usable_number_string_array(&["","235"]));
        assert!(is_usable_number_string_array(&["235"]));
    }

    #[test]
    fn test_is_usable_number_string_vector() {
        assert!(is_usable_number_string_vector(&vec!["1","33.33","4"]));
        assert!(!is_usable_number_string_vector(&vec!["1"," 2 3 5 "]));
        assert!(!is_usable_number_string_vector(&vec!["1s","235"]));
        assert!(!is_usable_number_string_vector(&vec![".","235"]));
        assert!(!is_usable_number_string_vector(&vec!["","235"]));
        assert!(is_usable_number_string_vector(&vec!["235"]));
    }

    #[test]
    fn test_round_to_f64_precision() {
        assert_eq!(round_to_f64_precision(1234.56789123457890, 4),1234.5679);
        assert_eq!(round_to_f64_precision(1234.0, 4),1234.0);
    }

    // Object Groups of Procedures, defined by traits, structs and
    // "impl" implementation groups.

    // HistogramOfX and RangeOccurrence

    #[test]
    fn test_construct_rangeoccurrence() {
        let mut roo = RangeOccurrence::new(0.0,1.1);
        assert_eq!(roo.count,0);
        assert_eq!(roo.start_no,0.0);
        assert_eq!(roo.stop_no,1.1);
        assert!(!roo.has_overlap(1.1,2.2));
        assert!(roo.is_in_range(1.0));
        roo.add_to_count();
        assert_eq!(roo.count,1);
    }

    // SumsOfPowers

    // VectorOfX, VectorOfContinuous, VectorOfDiscrete

    // VectorTable

}

//345678901234567890123456789012345678901234567890123456789012345678901234567890
// End of WPMS2023.naive.rs
