//345678901234567890123456789012345678901234567890123456789012345678901234567890
// SamesLib.neophyte.rs

#![ allow(unused)]

macro_rules! collection_csv_line_fmt_str {
    () => {
        "{},{}\n{},{}\n{},{}\n{},{}\n{},{}\n{},{}\n{},{}\n{},{}\n{},{}\n{},{}\n{},{}\n{},{}\n{},{}\n{},{}\n{},{}\n{},{}\n"
    }
}

macro_rules! collection_csv_table_fmt_str {
    () => {
        "{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{}\n"
    }
}

macro_rules! collection_json_table_fmt_str {
    () => {
        "
{{
    \"{}\":  \"{}\",
    \"{}\":  \"{}\",
    \"{}\":  \"{}\",
    \"{}\":  \"{}\",
    \"{}\":  \"{}\",
    \"{}\":  \"{}\",
    \"{}\":  \"{}\",
    \"{}\":  \"{}\",
    \"{}\":  \"{}\",
    \"{}\":  \"{}\",
    \"{}\":  \"{}\",
    \"{}\":  \"{}\",
    \"{}\":  \"{}\",
    \"{}\":  \"{}\",
    \"{}\":  \"{}\",
    \"{}\":  \"{}\",
}}
"
    }
}

use csv::ReaderBuilder;
use csv::StringRecord;
use regex::Regex;
use std::collections::*;
use std::error::Error;
use std::fs::read_to_string;

//345678901234567890123456789012345678901234567890123456789012345678901234567890
// Validation Errors

#[derive(thiserror::Error, Debug, Clone)]
pub enum ValidationError {
    #[error("Adjacent Endpoints {0}, {1} unequal")]
    AdjacentRangeEndpointsUnequal(f64,f64),
    #[error("Argument error:  {0}")]
    ArgumentError(String),
    #[error("Calculation overflow for field {0}")]
    CalculationOverflow(String),
    #[error("Calculation invalid with zero value n: {0}")]
    CalculationInvalidWithZeroElements(usize),
    #[error("String number {0} exceeds float capacity")]
    FloatCapacityExceeded(String),
    #[error("Invalid argument: {0}")]
    InvalidArgument(String),
    #[error("Invalid index: {0} out of range [{1},{2}]")]
    InvalidIndex(usize,usize,usize),
    #[error("Invalid VectorObject: Index {0} is NOT for a Vector class of type {1}.")]
    InvalidVectorObject(usize,String),
    #[error("Method may only be used with Differences from Mean Data.")]
    MethodOnlyForDiffFromMeanData(),
    #[error("Method may only be used with Sums of Xs Data.")]
    MethodOnlyForSumOfXsData(),
    #[error("No range found for value: '{0}'")]
    NoRangeFoundForValue(f64),
    #[error("Option {0} may NOT be used here")]
    OptionMayNotBeUsedHere(String),
    #[error("Parse error on would be number string {0}")]
    ParseErrorOnWouldBeNumberString(String),
    #[error("Procedure not programmed for '{0}' state")]
    ProcedureNotProgrammedForState(String),
    #[error("Range key {0} not equal to start no {1}")]
    RangeKeyNotEqualStartNo(i64,i64),
    #[error("Result May NOT be NONE")]
    ResultMayNotBeNone(),
    #[error("Summations Have Already Been Made")]
    SummationsHaveAlreadyBeenMade(usize),
    #[error("Value {0} is unexpectedly less than its predecessor {1}")]
    UnexpectedReducedValue(f64,f64),
    #[error("Value {0} at or above high stop point {1}")]
    ValueAtOrAboveHighStop(f64,f64),
    #[error("Value {0} below low limit {1}")]
    ValueBelowLowLimit(f64,f64),
    #[error("Value ({0}) Must be number String.")]
    ValueMustBeNumberString(String),
    #[error("Value May NOT be missing.")]
    ValueMayNotBeMissing(),
    #[error("Value {0} may not be negative.")]
    ValueMayNotBeNegative(f64),
    #[error("Value {0} may not be zero.")]
    ValueMayNotBeZero(f64),
    #[error("Low value {0} NOT below high value {1}")]
    ValueOrderWrong(f64,f64),
    #[error("Value Range Conflict [{0},{1}] overlaps [{2},{3}]")]
    ValueRangeConflict(f64,f64,f64,f64),
    #[error("Vector Pair Lengths ({0},{1}) must be equal.")]
    VectorPairLengthsNotEqual(usize,usize),
    #[error("Zero Result not considered valid.")]
    ZeroResultInvalid(),
}

//345678901234567890123456789012345678901234567890123456789012345678901234567890
// Global Procedures

/*
fn factorial(n: usize) -> BigUint {
    (1..=n).fold(BigUint::one(), |a, b| a * b)
}
 */

fn factorial(int_arg: u128) -> u128 {
    (1..=int_arg).fold(1, |acc, xs| acc * xs)
}

fn ffactorial(int_arg: u8) -> f64 {
    (1..=int_arg).fold(1.0, |acc, xs| acc * xs as f64)
}

pub fn from_f64_to_i128(precision: i32,subject_float: f64) -> i128 {
    let base: f64           = 10.0;
    let precision_base: f64 = base.powi( precision );
    let buffer: i128         = ( subject_float * precision_base ).round() as i128;
    return buffer;
}

pub fn from_i128_to_f64(precision: i32,subject_integer: i128) -> f64 {
    let base: f64           = 10.0;
    let precision_base: f64 = base.powi( precision );
    let newfloat            = subject_integer as f64 / precision_base;
    return newfloat;
}

pub fn get_vector_of_f64_from_strings(v_a: &Vec<String>) -> Result<Vec<f64>,ValidationError> {
    let mut vb: Vec<f64>    = Vec::new();
    for element in v_a.iter() {
        if is_a_num_str(element) {
            let x_float: f64 = match element.to_string().trim().parse::<f64>() {
                Ok(b)       => b,
                Err(_err)   => return Err(ValidationError::ParseErrorOnWouldBeNumberString(element.to_string())),
            };
            vb.push(x_float.to_owned());
        } else {
            return Err(ValidationError::ParseErrorOnWouldBeNumberString(element.to_string()));
        }
    }
    return Ok(vb);
}

pub fn generate_mode_from_frequency_aa(faa_a: &BTreeMap<String, u32>) -> Option<String> {
    let mut k: String = "".to_string();
    let mut m: u32 = 0;
    let mut candidates: HashSet<String> = HashSet::new();
    for (key, &value) in faa_a.iter() {
        if value == m {
            candidates.insert(key.to_string());
        }
        if value > m {
            candidates.clear();
            candidates.insert(key.to_string());
            k = key.to_string().clone();
            m = value;
        }
    }
    if m == 1 {
        return None;
    }
    if candidates.len() > 1 {
        return None;
    }
    return Some(k);
}

pub fn insert_op_data_to_aa(operation_option_output: Option<f64>,aa_buffer: &mut BTreeMap<String, String>,data_id: &str) {
    let string_data = match operation_option_output {
        None            => "None".to_string(),
        Some(buffer)    => format!("{}",buffer),
    }; 
    aa_buffer.insert(data_id.to_string(),string_data);
}

pub fn is_a_num_str(str_a: &str) -> bool {
    let sstr = str_a.trim();
    let re = Regex::new(r"^-?\d*\.?\d+$").unwrap();
    if re.is_match(sstr) {
        return true;
    }
    return false;
}

pub fn is_usable_number_str_array(a_a: &[&str]) -> bool {
    for element in a_a.iter() {
        if is_a_num_str(element) {
            continue;
        }
        return false;
    }
    return true;
}

pub fn is_usable_number_string_array(a_a: &[String]) -> bool {
    for element in a_a.iter() {
        if is_a_num_str(element) {
            continue;
        }
        return false;
    }
    return true;
}

pub fn is_usable_number_str_vector(v_a: &Vec<&str>) -> bool {
    for element in v_a.iter() {
        if is_a_num_str(element) {
            continue;
        }
        return false;
    }
    return true;
}

pub fn is_usable_number_string_vector(v_a: &Vec<String>) -> bool {
    for element in v_a.iter() {
        if is_a_num_str(element) {
            continue;
        }
        return false;
    }
    return true;
}

pub fn is_whitespace_only(str_a: &str) -> bool {
    let sstr = str_a.trim();
    if sstr.len() > 0 {
        return false;
    }
    return true;
}

pub fn parse_float_left_of_decimal(subject_float: f64) -> f64 {
    let leftside    = subject_float.floor() as f64;
    return leftside;
}

pub fn parse_float_right_of_decimal(subject_float: f64,precision: i32) -> f64 {
    let leftside    = subject_float.floor() as f64;
    let rightside   = subject_float - leftside;
    let base: f64           = 10.0;
    let precision_base: f64 = base.powi( precision );
    let buffer: f64         = ( rightside * precision_base ).round();
    let newfloat            = buffer / precision_base;
    return newfloat;
}

pub fn push_i128_from_f64(precision: i32,subject_float: f64, sorting_vector: &mut Vec<i128>) {
    // Should not require error handling because the values are already vetted.
    let base: f64           = 10.0;
    let precision_base: f64 = base.powi( precision );
    let buffer: i128         = ( subject_float * precision_base ).round() as i128;
    sorting_vector.push(buffer);
}

pub fn round_to_f64_precision(subject_float: f64, precision_digits: i32) -> f64 {
    let base: f64           = 10.0;
    let precision_base: f64 = base.powi( precision_digits );
    let buffer: f64         = ( subject_float * precision_base ).round();
    let newfloat            = buffer / precision_base;
    return newfloat;
}

pub fn zero_decimal_effective(precision: i32,subject_float:f64) -> bool {
    let base: f64           = 10.0;
    let precision_base: f64 = base.powi( precision );
    let rightfloat          = parse_float_right_of_decimal(subject_float,precision);
    let augmented           = rightfloat * precision_base;
    if augmented as i64 == 0 {
        return true;
    }
    return false;
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
        // Probably need to make this check start_no is lt stop_no, and
        // return Result.  TBD.
        let mut buffer: RangeOccurrence = Default::default();
        buffer.start_no = start_no;
        buffer.stop_no = stop_no;
        return buffer;
    }

}

pub struct HistogramOfX {
    frequency_aa: BTreeMap<i64, RangeOccurrence>,
    max: f64,
    min: f64,
    sentinal_multiplier: i64,
}

pub trait HistogramMethods {
    fn _float_to_sentinal(&self,start_no: f64) -> i64;
    //fn _sentinal_to_float(sentinal_no: i64) -> f64;
    fn _validate_no_overlap(&self,start_no: f64, stop_no: f64) -> Result<(), ValidationError>;
    fn add_to_counts(&mut self, x_float: f64) -> Result<(), ValidationError>;
    fn generate_count_collection(&self) -> Vec<(f64,f64,usize)>;
    fn new(lowest_value: f64, highest_value: f64) -> Result<HistogramOfX,ValidationError>;
    fn new_from_desired_segment_count(start_no: f64,max_no: f64,desired_segment_count: u8,extra_margin: f64) -> Result<HistogramOfX,ValidationError>;
    fn new_from_uniform_segment_size(start_no: f64,max_no: f64,segment_size: f64) -> Result<HistogramOfX,ValidationError>;
    fn set_occurrence_range(&mut self,start_no: f64,stop_no: f64) -> Result<(), ValidationError>;
    fn validate_ranges_complete(&self) -> Result<(), ValidationError>;
}

impl Default for HistogramOfX {
    fn default() -> Self {
        HistogramOfX {
            frequency_aa: BTreeMap::new(),
            max: 0.0,
            min: 0.0,
            sentinal_multiplier: 10_000,
        }
    }
}

impl HistogramMethods for HistogramOfX {

    fn _float_to_sentinal(&self,start_no: f64) -> i64 {
        let fbuffer = start_no * self.sentinal_multiplier as f64;
        return fbuffer as i64
    }

    /*
    fn _sentinal_to_float(&self,sentinal: i64) -> f64 {
        let fbuffer = sentinal as f64 / self.sentinal_multiplier as f64;
        return fbuffer
    }
     */

    fn _validate_no_overlap(&self,start_no: f64, stop_no: f64) -> Result<(), ValidationError> {
        if start_no >= stop_no {
            return Err(ValidationError::ValueOrderWrong(start_no,stop_no));
        }
        for (_lsentinal, lroo) in &self.frequency_aa {
            if lroo.has_overlap(start_no,stop_no) {
                return Err(ValidationError::ValueRangeConflict(start_no,stop_no,lroo.start_no,lroo.stop_no));
            }
        }
        return Ok(());
    }

    fn add_to_counts(&mut self, x_float: f64) -> Result<(), ValidationError> {
        for (_lsentinal, lroo) in &mut self.frequency_aa {
            if x_float < lroo.stop_no {
                lroo.add_to_count();
                return Ok(());
            }
        }
        return Err(ValidationError::NoRangeFoundForValue(x_float));
    }

    fn generate_count_collection(&self) -> Vec<(f64,f64,usize)> {
        let mut orderedlist: Vec<(f64,f64,usize)> = Vec::new();
        for (_lsentinal, lroo) in &self.frequency_aa {
            println!("trace 5 generate_count_collection {_lsentinal}");
            let tuplebuffer = (lroo.start_no,lroo.stop_no,lroo.count);
            orderedlist.push(tuplebuffer);
        }
        return orderedlist;
    }

    fn new(lowest_value: f64, highest_value: f64) -> Result<Self,ValidationError> {
        if lowest_value >= highest_value {
            return Err(ValidationError::ValueOrderWrong(lowest_value,highest_value));
        }
        let mut buffer: HistogramOfX = Default::default();
        buffer.max              = highest_value;
        buffer.min              = lowest_value;
        return Ok(buffer);
    }

    fn new_from_desired_segment_count(start_no: f64,max_no: f64,desired_segment_count: u8,extra_margin: f64) -> Result<Self,ValidationError> {
        let totalbreadth    = max_no - start_no + 1.0 + extra_margin as f64;
        let segmentsize     = totalbreadth / desired_segment_count as f64;
        let localo          = HistogramOfX::new_from_uniform_segment_size(start_no,max_no,segmentsize)?;
        return Ok(localo);
    }

    fn new_from_uniform_segment_size(start_no: f64,max_no: f64,segment_size: f64) -> Result<Self,ValidationError> {
        if start_no >= max_no {
            return Err(ValidationError::ValueOrderWrong(start_no,max_no));
        }
        let mut localo: HistogramOfX    = HistogramOfX::new(start_no,max_no)?;
        let mut bottomno                = start_no;
        let mut topno                   = bottomno + segment_size;
        while bottomno <= max_no {
            localo.set_occurrence_range(bottomno,topno)?;
            bottomno    = topno;
            topno       += segment_size;
        }
        return Ok(localo);
    }

    fn set_occurrence_range(&mut self,start_no: f64,stop_no: f64) -> Result<(), ValidationError> {
        if start_no >= stop_no {
            return Err(ValidationError::ValueOrderWrong(start_no,stop_no));
        }
        self._validate_no_overlap(start_no,stop_no)?;
        let lsentinal = self._float_to_sentinal(start_no);
        self.frequency_aa.insert(lsentinal, RangeOccurrence::new(start_no,stop_no));
        return Ok(());
    }

    fn validate_ranges_complete(&self) -> Result<(), ValidationError> {
        let mut i = 0;
        let mut last_stop_no = 0.0;
        for (&lsentinal, lroo) in &self.frequency_aa {
            let lscopy = self._float_to_sentinal(lroo.start_no);
            if lsentinal != lscopy {
                return Err(ValidationError::RangeKeyNotEqualStartNo(lsentinal,lscopy));
            }
            if i == 0 {
                if lroo.start_no > self.min {       // NOTE:  Start may be before the minimum,
                                                    // but NOT after it, as minimum value must
                                                    // be included in the first segment.
                    return Err(ValidationError::ValueBelowLowLimit(self.min,lroo.start_no));
                }
            } else {
                if last_stop_no != lroo.start_no {
                    return Err(ValidationError::AdjacentRangeEndpointsUnequal(last_stop_no,lroo.start_no));
                }
            }
            i += 1;
            last_stop_no = lroo.stop_no;
        }

        if self.max > last_stop_no {
            return Err(ValidationError::ValueAtOrAboveHighStop(self.max,last_stop_no));
        }
        return Ok(());
    }

}

//345678901234567890123456789012345678901234567890123456789012345678901234567890
//345678901234567890123456789012345678901234567890123456789012345678901234567890
// SumsOfPowers

pub trait SumsOfPowersAccess {
    fn calculate_pearsons_first_skewness_coefficient(a_mean: f64,mode_float: f64,std_dev: f64) -> Result<f64, ValidationError>;
    fn calculate_pearsons_second_skewness_coefficient(a_mean: f64,median_float: f64,std_dev: f64) -> Result<f64, ValidationError>;
    fn new(population_distribution: bool) -> Self;
    fn _calculate_second_moment_subject_xs(&self) -> Result<f64, ValidationError>;
    fn _calculate_third_moment_subject_xs(&self) -> Result<f64, ValidationError>;
    fn _calculate_fourth_moment_subject_xs(&self) -> Result<f64, ValidationError>;
    fn add_to_sums(&mut self,s_float: f64);
    fn calculate_excess_kurtosis_2_jr_r(&self) -> Result<f64, ValidationError>;
    fn generate_excess_kurtosis_3_365datascience(&self) -> Result<f64, ValidationError>;
    fn calculate_kurtosis_biased_diff_from_mean_calculation(&self) -> Result<f64, ValidationError>;
    fn calculate_kurtosis_unbiased_diff_from_mean_calculation(&self) -> Result<f64, ValidationError>;
    fn calculate_natural_estimator_of_population_skewness_g1(&self) -> Result<f64, ValidationError>;
    fn calculate_variance_using_subject_as_diffs(&self) -> Result<f64, ValidationError>;
    fn calculate_variance_using_subject_as_sum_xs(&self) -> Result<f64, ValidationError>;
    fn generate_natural_estimator_of_population_skewness_b1(&self) -> Result<f64, ValidationError>;
    fn generate_standard_deviation(&self) -> Result<f64, ValidationError>;
    fn generate_third_definition_of_sample_skewness_g1(&self) -> Result<f64, ValidationError>;
    fn request_kurtosis(&self) -> Result<f64, ValidationError>;
    fn request_skewness(&self,formula_id: u8) -> Result<f64, ValidationError>;
    fn set_to_diffs_from_mean_state(&mut self,sum_xs: f64,n_a: usize) -> Result<(), ValidationError>;
}

pub struct SumsOfPowers {
    arithmetic_mean:            f64,
    diff_from_mean_inputs_used: bool,
    n:                          usize,
    population:                 bool,
    sum_of_xs:                  f64,
    sum_power_of_2:             f64,
    sum_power_of_3:             f64,
    sum_power_of_4:             f64,
}

impl Default for SumsOfPowers {
    fn default() -> Self {
        SumsOfPowers {
            arithmetic_mean:            0.0,
            diff_from_mean_inputs_used: false,
            n:                          0,
            population:                 false,
            sum_of_xs:                  0.0,
            sum_power_of_2:             0.0,
            sum_power_of_3:             0.0,
            sum_power_of_4:             0.0,
        }
    }
}

impl SumsOfPowersAccess for SumsOfPowers {

    // NOTE:  The main merit to doing it this way is as a teaching or illustration
    // tool to show the two parallel patterns.  Probably this is not a good way
    // to implement it in most or any production situations.

    fn calculate_pearsons_first_skewness_coefficient(a_mean: f64,mode_float: f64,std_dev: f64) -> Result<f64, ValidationError> {
        // See 2023/11/05 "Pearson's first skewness coefficient" in:
        //   https://en.wikipedia.org/wiki/Skewness
        if std_dev == 0.0 {
            return Err(ValidationError::ValueMayNotBeZero(std_dev));
        }
        let sc  = ( a_mean - mode_float ) / std_dev;
        return Ok( sc );
    }

    fn calculate_pearsons_second_skewness_coefficient(a_mean: f64,median_float: f64,std_dev: f64) -> Result<f64, ValidationError> {
        // See 2023/11/05 "Pearson's second skewness coefficient" in:
        //   https://en.wikipedia.org/wiki/Skewness
        if std_dev == 0.0 {
            return Err(ValidationError::ValueMayNotBeZero(std_dev));
        }
        let sc  = ( a_mean - median_float ) / std_dev;
        return Ok( sc );
    }

    fn _calculate_second_moment_subject_xs(&self) -> Result<f64, ValidationError> {
        //   Sum( xi - mu )**2 == Sum(xi**2) - (1/n)(amean**2)
        // Note I checked this one at:
        //   https://math.stackexchange.com/questions/2569510/proof-for-sum-of-squares-formula-statistics-related
        //
        if self.diff_from_mean_inputs_used {
            return Err(ValidationError::MethodOnlyForSumOfXsData());
        }
        if self.n == 0 {
            return Err(ValidationError::ValueMayNotBeZero(self.n as f64));
        }
        let nf              = self.n as f64;
        let nreciprocal     = 1.0 / nf;
        let first           = self.sum_power_of_2;
        let meansquared     = self.arithmetic_mean.powi(2);
        let second          = nreciprocal * meansquared;
        let ssx             = first - second;
        return Ok(ssx);
    }

    fn _calculate_third_moment_subject_xs(&self) -> Result<f64, ValidationError> {
        // My algegra, using unreduced arithmetic mean parts because that becomes complicated
        // when going to sample means, leads to a simple Pascal Triangle pattern:
        // My algegra: Sum( xi - mu )**3 ==
        //   Sum(xi**3) - 3*Sum(xi**2)*amean + 3*Sum(xi)*(amean**2) - amean**3
        if self.diff_from_mean_inputs_used {
            return Err(ValidationError::MethodOnlyForSumOfXsData());
        }
        let first       = self.sum_power_of_3;
        let second      = 3.0 * self.sum_power_of_2 * self.arithmetic_mean;
        let meansquared = self.arithmetic_mean.powi(2);
        let third       = 3.0 * self.sum_of_xs * meansquared;
        let fourth      = self.arithmetic_mean.powi(3);
        let result      = first - second + third - fourth;
        return Ok(result);
    }

    fn _calculate_fourth_moment_subject_xs(&self) -> Result<f64, ValidationError> {
        // My algegra, using unreduced arithmetic mean parts because that becomes complicated
        // when going to sample means, leads to a simple Pascal Triangle pattern:
        // My algegra: Sum( xi - mu )**4 ==
        //   Sum(xi**4) - 4*Sum(xi**3)*amean + 6*Sum(xi**2)(amean**2) - 4**Sum(xi)*(amean**3) + amean**4
        if self.diff_from_mean_inputs_used {
            return Err(ValidationError::MethodOnlyForSumOfXsData());
        }
        let first       = self.sum_power_of_4;
        let second      = 4.0 * self.sum_power_of_3 * self.arithmetic_mean;
        let meansquared = self.arithmetic_mean.powi(2);
        let third       = 6.0 * self.sum_power_of_2 * meansquared;
        let meancubed   = self.arithmetic_mean.powi(3);
        let fourth      = 4.0 * self.sum_of_xs * meancubed;
        let fifth       = self.arithmetic_mean.powi(4);
        let result      = first - second + third - fourth + fifth;
        return Ok(result);
    }

    fn add_to_sums(&mut self,s_float: f64) {
        if ! self.diff_from_mean_inputs_used {
            self.n += 1;
            self.sum_of_xs  += s_float;

            self.arithmetic_mean = self.sum_of_xs / self.n as f64;
        }
        self.sum_power_of_2 += s_float * s_float;
        self.sum_power_of_3 += s_float * s_float * s_float;
        self.sum_power_of_4 += s_float * s_float * s_float * s_float;
    }

    fn calculate_excess_kurtosis_2_jr_r(&self) -> Result<f64, ValidationError> {
        //  2018-01-04 by Jonathan Regenstein https://rviews.rstudio.com/2018/01/04/introduction-to-kurtosis/
        if ! self.diff_from_mean_inputs_used {
            return Err(ValidationError::MethodOnlyForDiffFromMeanData());
        }
        if self.n == 0 {
            return Err(ValidationError::ValueMayNotBeZero(self.n as f64));
        }
        if self.sum_power_of_2 == 0.0 {
            return Err(ValidationError::ValueMayNotBeZero(self.sum_power_of_2));
        }
        let nf          = self.n as f64;
        let numerator   = self.sum_power_of_4 / nf;
        let denominator = ( self.sum_power_of_2 / nf ).powi(2);
        let ek          = ( numerator / denominator ) - 3.0;
        return Ok(ek);
    }

    fn generate_excess_kurtosis_3_365datascience(&self) -> Result<f64, ValidationError> {
        //  https://365datascience.com/calculators/kurtosis-calculator/
        if ! self.diff_from_mean_inputs_used {
            return Err(ValidationError::MethodOnlyForDiffFromMeanData());
        }
        let nf                  = self.n as f64;
        let stddev              = self.generate_standard_deviation()?;
        let s4                  = stddev.powi(4);
        if s4 == 0.0 {
            return Err(ValidationError::ValueMayNotBeZero(s4));
        }

        let leftnumerator       = nf * ( nf + 1.0 );
        let leftdenominator     = ( nf - 1.0 ) * ( nf - 2.0 ) * ( nf - 3.0 );
        if leftdenominator == 0.0 {
            return Err(ValidationError::ValueMayNotBeZero(leftdenominator));
        }
        let left                = leftnumerator / leftdenominator;

        let middle              = self.sum_power_of_4 / s4;

        let rightnumerator      = 3.0 * ( ( nf - 1.0 ).powi(2) );
        let rightdenominator    = ( nf - 2.0 ) * ( nf - 3.0 );
        if rightdenominator == 0.0 {
            return Err(ValidationError::ValueMayNotBeZero(rightdenominator));
        }
        let right               = rightnumerator / rightdenominator;
        let ek                  = left * middle - right;
        return Ok(ek);
    }

    fn calculate_kurtosis_biased_diff_from_mean_calculation(&self) -> Result<f64, ValidationError> {
        // See 2023/11/05 "Standard biased estimator" in:
        //   https://en.wikipedia.org/wiki/Kurtosis
        if ! self.diff_from_mean_inputs_used {
            return Err(ValidationError::MethodOnlyForDiffFromMeanData());
        }
        let nreciprocal     = 1.0 / self.n as f64;
        let numerator       = nreciprocal * self.sum_power_of_4;
        let denominternal   = nreciprocal * self.sum_power_of_2;
        let denominator     = denominternal * denominternal;
        if denominator == 0.0 {
            return Err(ValidationError::ValueMayNotBeZero(denominator));
        }
        let g2              = numerator / denominator;
        return Ok(g2);
    }

    fn calculate_kurtosis_unbiased_diff_from_mean_calculation(&self) -> Result<f64, ValidationError> {
        // See 2023/11/05 "Standard unbiased estimator" in:
        //   https://en.wikipedia.org/wiki/Kurtosis
        if self.n <= 3 {
            let m = "This formula wll not be executed for N <= 3.";
            return Err(ValidationError::ArgumentError(m.to_string()));
        }
        if ! self.diff_from_mean_inputs_used {
            return Err(ValidationError::MethodOnlyForDiffFromMeanData());
        }
        let nf                  = self.n as f64;

        let leftnumerator       = ( nf + 1.0 ) * nf * ( nf - 1.0 );
        let leftdenominator     = ( nf - 2.0 ) * ( nf - 3.0 );
        if leftdenominator == 0.0 {
            return Err(ValidationError::ValueMayNotBeZero(leftdenominator));
        }
        let left                = leftnumerator / leftdenominator;

        let middle              = self.sum_power_of_4 / ( self.sum_power_of_2.powi(2) );

        let rightnumerator      = ( nf - 1.0 ).powi(2);
        let rightdenominator    = ( nf - 2.0 ) * ( nf - 3.0 );
        if rightdenominator == 0.0 {
            return Err(ValidationError::ValueMayNotBeZero(rightdenominator));
        }
        let right               = rightnumerator / rightdenominator;
        let sue_g2              = left * middle - right;

        return Ok(sue_g2);
    }

    // https://en.wikipedia.org/wiki/IEEE_754#Exception_handling

    fn calculate_natural_estimator_of_population_skewness_g1(&self) -> Result<f64, ValidationError> {
        // See 2023/11/05 "Sample Skewness" in:
        //   https://en.wikipedia.org/wiki/Skewness
        let inside_den: f64;
        let nreciprocal = 1.0 / self.n as f64;
        let numerator: f64;
        if self.diff_from_mean_inputs_used {
            inside_den  = nreciprocal * self.sum_power_of_2;
            numerator   = nreciprocal * self.sum_power_of_3;
        } else {
            let second  = self._calculate_second_moment_subject_xs()?;
            let third   = self._calculate_third_moment_subject_xs()?;

            inside_den  = nreciprocal * second;
            numerator   = nreciprocal * third;
        }
        if inside_den < 0.0 {
            return Err(ValidationError::ValueMayNotBeNegative(inside_den));
        }
        let denominator = ( inside_den.sqrt() ).powi(3);
        if denominator == 0.0 {
            return Err(ValidationError::ValueMayNotBeZero(denominator));
        }
        let g1          = numerator / denominator;
        return Ok(g1);
    }

    fn calculate_variance_using_subject_as_diffs(&self) -> Result<f64, ValidationError> {
        if ! self.diff_from_mean_inputs_used {
            return Err(ValidationError::MethodOnlyForDiffFromMeanData());
        }
        let nf          = self.n as f64;
        let v: f64;
        if self.population {
            if nf == 0.0 {
                return Err(ValidationError::ValueMayNotBeZero(nf));
            }
            v           = self.sum_power_of_2 / nf;
        } else {
            let denominator = nf - 1.0;
            if denominator == 0.0 {
                return Err(ValidationError::ValueMayNotBeZero(denominator));
            }
            v           = self.sum_power_of_2 / denominator;
        }
        return Ok(v);
    }

    fn calculate_variance_using_subject_as_sum_xs(&self) -> Result<f64, ValidationError> {
        if self.diff_from_mean_inputs_used {
            return Err(ValidationError::MethodOnlyForSumOfXsData());
        }
        let ameansquared    = self.arithmetic_mean * self.arithmetic_mean;
        let nf              = self.n as f64;
        let numerator       = self.sum_power_of_2 - nf * ameansquared;
        let v: f64;
        if self.population {
            if nf == 0.0 {
                return Err(ValidationError::ValueMayNotBeZero(nf));
            }
            v               = numerator / nf;
        } else {
            let denominator     = nf - 1.0;
            if denominator == 0.0 {
                return Err(ValidationError::ValueMayNotBeZero(denominator));
            }
            v               = numerator / denominator;
        }
        return Ok(v);
    }

    fn generate_natural_estimator_of_population_skewness_b1(&self) -> Result<f64, ValidationError> {
        // See 2023/11/05 "Sample Skewness" in:
        //   https://en.wikipedia.org/wiki/Skewness
        if self.n == 0 {
            return Err(ValidationError::ValueMayNotBeZero(self.n as f64));
        }
        let nf              = self.n as f64;
        let nreciprocal     = 1.0 / nf;
        let numerator: f64;
        if self.diff_from_mean_inputs_used {
            numerator       = nreciprocal * self.sum_power_of_3;
        } else {
            let thirdmoment = self._calculate_third_moment_subject_xs()?;
            numerator   = nreciprocal * thirdmoment;
        }
        let stddev          = self.generate_standard_deviation()?;
        let denominator     = stddev.powi(3);
        if denominator == 0.0 {
            return Err(ValidationError::ValueMayNotBeZero(denominator));
        }
        let b1              = numerator / denominator;
        return Ok(b1);
    }

    fn generate_standard_deviation(&self) -> Result<f64, ValidationError> {
        let v: f64;
        if self.diff_from_mean_inputs_used {
            v = self.calculate_variance_using_subject_as_diffs()?;
        } else {
            v = self.calculate_variance_using_subject_as_sum_xs()?;
        }
        if v < 0.0 {
            return Err(ValidationError::ValueMayNotBeNegative(v));
        }
        let stddev = v.sqrt();
        return Ok(stddev);
    }

    fn generate_third_definition_of_sample_skewness_g1(&self) -> Result<f64, ValidationError> {
        // See 2023/11/05 "Sample Skewness" in:
        //   https://en.wikipedia.org/wiki/Skewness
        let b1              = self.generate_natural_estimator_of_population_skewness_b1()?;
        let nf              = self.n as f64;
        let nfsquared       = nf.powi(2);
        let k3              = nfsquared * b1;
        let k2_3s2          = ( nf - 1.0 ) * ( nf - 2.0 );
        if k2_3s2 == 0.0 {
            return Err(ValidationError::ValueMayNotBeZero(k2_3s2));
        }
        let ss_g1           = k3 / k2_3s2;
        return Ok(ss_g1);
    }

    fn new(population_distribution: bool) -> Self {
        let mut buffer: SumsOfPowers    = Default::default();
        buffer.population               = population_distribution;
        return buffer;
    }

    fn request_kurtosis(&self) -> Result<f64, ValidationError> {
        // This of course needs to be expanded to use both diffs from mean ANd sum of Xs calculation.
        let kurtosis = self.calculate_kurtosis_unbiased_diff_from_mean_calculation()?;
        return Ok(kurtosis);
    }

    fn request_skewness(&self,formula_id: u8) -> Result<f64, ValidationError> {
        /* NOTE:  Ruby and Python3 code are misdocumented regarding population skewnesss in that they fail
            prematurely.  See called functions below.
         */
        let skewness: f64;
        match formula_id {
            1 => skewness = self.generate_natural_estimator_of_population_skewness_b1()?,
            2 => skewness = self.calculate_natural_estimator_of_population_skewness_g1()?,
            3 => skewness = self.generate_third_definition_of_sample_skewness_g1()?,
            _ => {
                let m = "There is no such skewness formula {formulaId} implemented at this time.";
                return Err(ValidationError::ArgumentError(m.to_string()));
            }
        }
        return Ok(skewness);
    }

    fn set_to_diffs_from_mean_state(&mut self,sum_xs: f64,n_a: usize) -> Result<(), ValidationError> {
        if self.n > 0 {
            return Err(ValidationError::SummationsHaveAlreadyBeenMade(self.n));
        }
        self.diff_from_mean_inputs_used = true;
        self.n                          = n_a;
        self.sum_of_xs                  = sum_xs;

        if self.n == 0 {
            return Err(ValidationError::ValueMayNotBeZero(self.n as f64));
        }
        self.arithmetic_mean            = sum_xs / self.n as f64;
        return Ok(());
    }

}

//345678901234567890123456789012345678901234567890123456789012345678901234567890
//345678901234567890123456789012345678901234567890123456789012345678901234567890
// VectorOfX - Representing a kind of base class area.

type BadDataAction  = &'static str;

const BLANKFIELD:    BadDataAction  = "BlankField";
const DEFAULTFILL:   BadDataAction  = "DefaultFill";
const EXCLUDEROW:    BadDataAction  = "ExcludeRow";
const FAIL:          BadDataAction  = "Fail";
const SKIPDATAITEM:  BadDataAction  = "SkipDataItem";
const ZEROFLOAT:     BadDataAction  = "ZeroFloat";
const ZEROINTEGER:   BadDataAction  = "ZeroInteger";

/*
    May not be able to use this for now:
let BadDataActionSet = HashSet::from([
    BLANKFIELD,
    DEFAULTFILL,
    EXCLUDEROW,
    FAIL,
    SKIPDATAITEM,
    ZEROFLOAT,
    ZEROINTEGER,
]);
 */

pub trait VectorOfX {
    fn get_count(&self) -> usize;
    fn get_in_precision(&self) -> i32;
    fn get_out_precision(&self) -> i32;
    fn get_implementation_name(&self) -> &'static str {
        return std::any::type_name::<Self>();
    }
    fn get_vector_of_strings(&self) -> Option<Vec<String>>;
    fn is_n_even(&self) -> bool;
    fn is_n_zero(&self) -> bool;
    fn load_from_str_vector(&mut self,vector_of_x: Vec<&str>,on_bad_data: BadDataAction) -> Result<(), ValidationError>;
    fn load_from_string_vector(&mut self,vector_of_x: Vec<String>,on_bad_data: BadDataAction) -> Result<(), ValidationError>;
    fn push_x_str(&mut self, x_str: &str,on_bad_data: BadDataAction) -> Result<(), ValidationError>;
    fn push_x_string(&mut self, x_string: String,on_bad_data: BadDataAction) -> Result<(), ValidationError>;
}

//345678901234567890123456789012345678901234567890123456789012345678901234567890
//345678901234567890123456789012345678901234567890123456789012345678901234567890
// VectorOfContinouos for floating point based distributions.  All Xs floats.

pub struct VectorOfContinuous {
    in_precision: i32,
    out_precision: i32,
    population: bool,
    sorted_vector_of_x: Vec<i128>,
    sums_of_powers_object: SumsOfPowers,
    use_diff_from_mean_calculations: bool,
    validate_string_numbers: bool,
    vector_of_x: Vec<f64>,
}

pub fn init_vector_of_continuous() -> VectorOfContinuous {
    VectorOfContinuous {
        in_precision: 4,
        out_precision: 4,
        population: false,
        sorted_vector_of_x: Vec::new(),
        sums_of_powers_object: SumsOfPowers::new(false),
        use_diff_from_mean_calculations: true,
        validate_string_numbers: false,
        vector_of_x: Vec::new(),
    }
}

pub fn init_vector_of_continuous_(in_precision: i32,out_precision: i32, population: bool, use_diff_from_mean_calculations: bool, validate_string_numbers: bool) -> VectorOfContinuous {
    VectorOfContinuous {
        in_precision,
        out_precision,
        population,
        sorted_vector_of_x: Vec::new(),
        sums_of_powers_object: SumsOfPowers::new(false),
        use_diff_from_mean_calculations,
        validate_string_numbers,
        vector_of_x: Vec::new(),
    }
}

impl VectorOfX for VectorOfContinuous {

    fn get_count(&self) -> usize {
        let n = self.vector_of_x.len();
        return n;
    }

    fn get_in_precision(&self) -> i32 {
        return self.in_precision;
    }

    fn get_out_precision(&self) -> i32 {
        return self.out_precision;
    }

    fn get_vector_of_strings(&self) -> Option<Vec<String>> {
        if self.is_n_zero() {
            return None;
        }
        let mut vb: Vec<String> = Vec::new();
        for lx in self.vector_of_x.iter() {
            let s   = format!("{:.prec$}", lx, prec = self.in_precision as usize);
            vb.push(s);
        }
        return Some(vb);
    }

    fn is_n_even(&self) -> bool {
        let n = self.get_count();
        if n % 2 == 0 {
            return true
        }
        return false;
    }

    fn is_n_zero(&self) -> bool {
        if self.get_count() == 0 {
            return true;
        }
        return false;
    }

    fn load_from_str_vector(&mut self,vector_of_x: Vec<&str>,on_bad_data: BadDataAction) -> Result<(),ValidationError> {
        for lx in vector_of_x.iter() {
            self.push_x_string(lx.to_string(),on_bad_data)?;
        }
        return Ok(());
    }

    fn load_from_string_vector(&mut self,vector_of_x: Vec<String>,on_bad_data: BadDataAction) -> Result<(),ValidationError> {
        for lx in vector_of_x.iter() {
            self.push_x_string(lx.to_string(),on_bad_data)?;
        }
        return Ok(());
    }

    fn push_x_str(&mut self,x_item: &str,on_bad_data: BadDataAction) -> Result<(), ValidationError> {
        self.push_x_string(x_item.to_string(),on_bad_data)?;
        return Ok(());
    }

    fn push_x_string(&mut self,x_item: String,on_bad_data: BadDataAction) -> Result<(), ValidationError> {
        let mut x_mut               = x_item.to_string();
        if ! is_a_num_str(x_mut.as_str()) {
            match on_bad_data {
                BLANKFIELD      => x_mut=" ".to_string(),
                DEFAULTFILL     => x_mut=" ".to_string(),
                EXCLUDEROW      => return Err(ValidationError::OptionMayNotBeUsedHere("ExcludeRow".to_string())),
                FAIL            => return Err(ValidationError::ValueMustBeNumberString(x_item)),
                SKIPDATAITEM    => return Ok(()),
                ZEROFLOAT       => x_mut="0.0".to_string(),
                ZEROINTEGER     => x_mut="0".to_string(),
                _               => panic!("Should never happen.  Programmer error."),
            };
        }
        let result                  = x_mut.trim().parse::<f64>();
        let x_float_unrounded:  f64 = match result {
            Ok(unrounded)       => unrounded,
            Err(_err)           => return Err(ValidationError::ParseErrorOnWouldBeNumberString(x_mut)),
        };
        let x_float                 = round_to_f64_precision(x_float_unrounded, self.in_precision);
        self.vector_of_x.push(x_float);
        return Ok(());
    }

}

impl VectorOfContinuous {

    const ARITHMETICMEANID: &str    = "ArithmeticMean";
    const ARMEANAADID:      &str    = "AMeanAAD"; // Average Absolute Deviation
    const COVID:            &str    = "CoefficientOfVariation";
    const GEOMETRICMEANID:  &str    = "GeometricMean";
    const HARMONICMEANID:   &str    = "HarmonicMean";
    const ISEVENID:         &str    = "IsEven";
    const KURTOSISID:       &str    = "Kurtosis";
    const MADID:            &str    = "MAD"; // Mean Absolute Difference  NOTE that this will not be addressed in acceptance tests due to a paucity of presence in common apps.
    const MAXID:            &str    = "Max";
    const MEDIANAADID:      &str    = "MedianAAD";// Median Absolute Deviation
    const MEDIANID:         &str    = "Median";
    const MINID:            &str    = "Min";
    const MODEID:           &str    = "Mode";
    const NID:              &str    = "N";
    const SKEWNESSID:       &str    = "Skewness";
    const STDDEVID:         &str    = "StandardDeviation";
    const SUMID:            &str    = "Sum";

    //fn _addUpXsToSumsOfPowers(populationCalculation=false,sumOfDiffs=true)
    // NOTE:  Usage differs here:  Need to address.TBD
    fn _add_up_xs_to_sums_of_powers(&mut self,population_calculation: bool,sum_of_diffs: bool) -> Result<(), ValidationError> {
        self.sums_of_powers_object  = SumsOfPowers::new(population_calculation);
        if sum_of_diffs {
            let n                   = self.get_count();
            let sum                 = self.calculate_sum();
            self.sums_of_powers_object.set_to_diffs_from_mean_state(sum,n)?;
        }
        if sum_of_diffs {
            let result              = self.calculate_arithmetic_mean();
            let amean               = match result {
                None            => return Err(ValidationError::ResultMayNotBeNone()),
                Some(buffer)    => buffer,
            };
            for lx in self.vector_of_x.iter() {
                let diff            = lx - amean;
                self.sums_of_powers_object.add_to_sums(diff);
            }
        } else {    // sum of Xs
            for lx in self.vector_of_x.iter() {
                self.sums_of_powers_object.add_to_sums(*lx);
            }
        }
        return Ok(());
    }

    fn _assure_sorted_vector_of_x(&mut self,force_sort: bool) {
        if self.sorted_vector_of_x.len() == self.vector_of_x.len() {
            if ! force_sort {
                return ();
            }
        }
        self.sorted_vector_of_x.clear();
        for lx in self.vector_of_x.iter() {
            push_i128_from_f64(self.in_precision,*lx,&mut self.sorted_vector_of_x);
        }
        self.sorted_vector_of_x.sort();
    }

    fn _decide_histogram_start_number(&mut self,use_start_number: bool,start_number: f64) -> f64 {
        let startno: f64;
        if use_start_number {
            startno = start_number;
        } else {
            let startnooption   = self.get_min();
            startno = match startnooption {
                None => 0.0,
                Some(minresult) => minresult,
            };
        }
        return startno;
    }

    pub fn calculate_arithmetic_mean(&self) -> Option<f64> {
        if self.is_n_zero() {
            return None;
        }
        let nf          = self.get_count() as f64;
        let sumxs       = self.calculate_sum();
        let unrounded   = sumxs / nf;
        let mean        = round_to_f64_precision(unrounded, self.out_precision);
        return Some(mean);
    }

    pub fn calculate_geometric_mean(&self) -> Option<f64> {
        if self.is_n_zero() {
            return None;
        }
        let nf          = self.get_count() as f64;
        let exponent    = 1.0 / nf;
        let productxs   = self.vector_of_x.clone().into_iter().reduce(|a, b| a * b)?;
        let unrounded   = productxs.powf(exponent);
        let rounded     = round_to_f64_precision(unrounded, self.out_precision);
        return Some(rounded);
    }

    pub fn calculate_harmonic_mean(&self) -> Result<Option<f64>, ValidationError> {
        if self.is_n_zero() {
            return Ok(None);
        }
        let nf                  = self.get_count() as f64;
        let mut sumreciprocals: f64 = 0.0;
        for lx in self.vector_of_x.iter() {
            if *lx == 0.0 {
                return Err(ValidationError::ValueMayNotBeZero(*lx));
            }
            sumreciprocals      += 1.0 / lx;
        }
        let unrounded           = nf / sumreciprocals;
        let rounded             = round_to_f64_precision(unrounded, self.out_precision);
        return Ok(Some(rounded));
    }

    pub fn calculate_quartile(&mut self,q_no: u8) -> Result<Option<f64>, ValidationError> {
        if self.is_n_zero() {
            return Ok(None);
        }
        /*
        if q_no < 0 {
            return Err(ValidationError::ValueMayNotBeNegative(q_no as f64));
        }
         */
        if 4 < q_no {
            let m = "Value q_no '{q_no}' may not be larger than 4.".to_string();
            return Err(ValidationError::ArgumentError(m));
        }
        self._assure_sorted_vector_of_x(false);
        let nf                          = self.get_count() as f64;
        let qindexfloat                 = q_no as f64 * ( nf - 1.0 ) / 4.0;
        let qvalue: f64;
        if zero_decimal_effective(self.in_precision,qindexfloat) {
            let qi                      = qindexfloat as usize;
            qvalue                      = from_i128_to_f64(self.in_precision,self.sorted_vector_of_x[qi]);
        } else {
            let thisquartilefraction    = parse_float_right_of_decimal(qindexfloat,self.in_precision);
            let portion0                = 1.0 - thisquartilefraction;
            let portion1                = 1.0 - portion0;
            let qi0                     = qindexfloat as usize;
            let qi1                     = qi0 + 1;
            let qv0                     = from_i128_to_f64(self.in_precision,self.sorted_vector_of_x[qi0]);
            let qv1                     = from_i128_to_f64(self.in_precision,self.sorted_vector_of_x[qi1]);
            qvalue                      = qv0 * portion0 + qv1 * portion1;
        }
        return Ok(Some(qvalue));
    }

    pub fn calculate_sum(&self) -> f64 {
        if self.is_n_zero() {
            return 0.0;
        }
        let sumxs = self.vector_of_x.iter().sum();
        return sumxs;
    }

    pub fn generate_average_absolute_deviation(&mut self,central_point_type: &str) -> Result<Option<f64>, ValidationError> {
        if self.is_n_zero() {
            return Ok(None);
        }
        let option: Option<f64>;
        match central_point_type {
            Self::ARITHMETICMEANID    =>    option   = self.calculate_arithmetic_mean(),
            Self::GEOMETRICMEANID     =>    option   = self.calculate_geometric_mean(),
            Self::HARMONICMEANID      =>    option   = self.calculate_harmonic_mean()?,
            Self::MAXID               =>    option   = self.get_max(),
            Self::MEDIANID            =>    option   = self.request_median(),
            Self::MINID               =>    option   = self.get_min(),
            Self::MODEID              =>    option   = self.generate_mode(),
            _ => {
                let m = "This Average Absolute Mean formula has not implemented a statistic for central point '{central_point_type}' at this time.".to_string();
                return Err(ValidationError::ArgumentError(m));
            },
        };
        let cpf: f64            = match option {
            None            => return Ok(None),
            Some(buffer)    => buffer,
        };
        let nf                              = self.get_count() as f64;
        let mut sumofabsolutediffs: f64         = 0.0;
        for lx in self.vector_of_x.iter() {
            let previous                    = sumofabsolutediffs;
            sumofabsolutediffs              += ( lx - cpf ).abs();
            if previous > sumofabsolutediffs {
                return Err(ValidationError::UnexpectedReducedValue(sumofabsolutediffs,previous));
            }
        }
        let unrounded           = sumofabsolutediffs / nf;
        let rounded             = round_to_f64_precision(unrounded, self.out_precision);
        return Ok(Some(rounded));
    }

    pub fn generate_coefficient_of_variation(&mut self) -> Result<Option<f64>, ValidationError> {
        if self.is_n_zero() {
            return Ok(None);
        }
        self._add_up_xs_to_sums_of_powers(self.population,self.use_diff_from_mean_calculations)?;
        let amean       = self.sums_of_powers_object.arithmetic_mean;
        if amean == 0.0 {
            return Err(ValidationError::ValueMayNotBeZero(amean));
        }
        let stddev      = self.sums_of_powers_object.generate_standard_deviation()?;
        let unrounded   = stddev / amean;
        let rounded     = round_to_f64_precision(unrounded, self.out_precision);
        return Ok(Some(rounded));
    }

    pub fn generate_histogram_aa_by_number_of_segments(&mut self,desired_segment_count: u8,use_start_number: bool,start_number: f64) -> Result<Option<Vec<(f64,f64,usize)>>, ValidationError> {
        if self.is_n_zero() {
            return Ok(None);
        }
        let extramargin     = 1.0;
        let lmax            = self.get_max().unwrap(); // Presuming from n > 0 this will always be a Some.
        let startno         = self._decide_histogram_start_number(use_start_number,start_number);
        let mut histo           = HistogramOfX::new_from_desired_segment_count(startno,lmax,desired_segment_count,extramargin)?;
        histo.validate_ranges_complete()?;
        for lx in self.vector_of_x.iter() {
            histo.add_to_counts(*lx)?;
        }
        let resultvectors   = histo.generate_count_collection();
        return Ok(Some(resultvectors));
    }

    pub fn generate_histogram_aa_by_segment_size(&mut self,desired_segment_size: f64,use_start_number: bool,start_number: f64) -> Result<Option<Vec<(f64,f64,usize)>>, ValidationError> {
        if self.is_n_zero() {
            return Ok(None);
        }
        let lmax            = self.get_max().unwrap(); // Presuming from n > 0 this will always be a Some.
        let startno         = self._decide_histogram_start_number(use_start_number,start_number);
        let mut histo           = HistogramOfX::new_from_uniform_segment_size(startno,lmax,desired_segment_size)?;
        histo.validate_ranges_complete()?;
        for lx in self.vector_of_x.iter() {
            histo.add_to_counts(*lx)?;
        }
        let resultvectors   = histo.generate_count_collection();
        return Ok(Some(resultvectors));
    }

    pub fn generate_mean_absolute_difference(&self) -> Result<Option<f64>, ValidationError> {
        // https://en.wikipedia.org/wiki/Mean_absolute_difference
        if self.is_n_zero() {
            return Ok(None);
        }
        let nf                      = self.get_count() as f64;
        let mut sumofabsolutediffs: f64 = 0.0;
        for lxi in self.vector_of_x.iter() {
            for lxj in self.vector_of_x.iter() {
                sumofabsolutediffs  += ( lxi - lxj ).abs();
            }
        }
        let denominator             = nf * ( nf - 1.0 );
        if denominator == 0.0 {
            return Err(ValidationError::ValueMayNotBeZero(denominator));
        }
        let unrounded               = sumofabsolutediffs / denominator;
        let rounded                 = round_to_f64_precision(unrounded, self.out_precision);
        return Ok(Some(rounded));
    }

    pub fn generate_mode(&self) -> Option<f64> {
        if self.is_n_zero() {
            return None;
        }
        let mut lsaa: BTreeMap<String,u32>    = BTreeMap::new();
        for lx in self.vector_of_x.iter() {
            let btkey = lx.to_string();
            match lsaa.get(&btkey) {
                Some(count) => lsaa.insert(btkey, count + 1),
                None        => lsaa.insert(btkey, 1),
            };
        }
        let option                      = generate_mode_from_frequency_aa(&lsaa);
        let modestr                     = match option {
            None            => return None,
            Some(buffer)    => buffer,
        };
        let modefloat                   = modestr.parse::<f64>().unwrap();
        return Some(modefloat);
    }

    pub fn get_max(&mut self) -> Option<f64> {
        if self.is_n_zero() {
            return None;
        }
        self._assure_sorted_vector_of_x(false);
        let max_opi128  = self.sorted_vector_of_x.iter().max()?;
        let max_opval   = from_i128_to_f64(self.in_precision,*max_opi128);
        return Some(max_opval);
    }

    pub fn get_min(&mut self) -> Option<f64> {
        if self.is_n_zero() {
            return None;
        }
        self._assure_sorted_vector_of_x(false);
        let min_opi128  = self.sorted_vector_of_x.iter().min()?;
        let min_opval   = from_i128_to_f64(self.in_precision,*min_opi128);
        return Some(min_opval);
    }

    pub fn get_x(&mut self,index_a: usize) -> Option<f64> {
        let n = self.get_count();
        if n <= index_a {
            return None;
        }
        return Some(self.vector_of_x[index_a]);
    }

    pub fn get_x_sorted(&mut self,index_a: usize) -> Option<f64> {
        let n = self.get_count();
        if n <= index_a {
            return None;
        }
        self._assure_sorted_vector_of_x(false); // in case update occurred from pushX.
        let buffer = from_i128_to_f64(self.in_precision,self.sorted_vector_of_x[index_a]);
        return Some(buffer);
    }

    pub fn load_from_f64(&mut self,vector_of_x: Vec<f64>) {
        for lx in vector_of_x.iter() {
            self.push_x(*lx);
        }
    }

    pub fn load_from_i32(&mut self,vector_of_x: Vec<i32>) {
        for lx in vector_of_x.iter() {
            self.push_x(*lx as f64);
        }
    }

    pub fn push_x(&mut self, x_float_unrounded: f64) {
        let x_float                 = round_to_f64_precision(x_float_unrounded, self.in_precision);
        self.vector_of_x.push(x_float);
    }

    pub fn request_excess_kurtosis(&mut self,formula_id: u8) -> Result<Option<f64>, ValidationError> {
        if self.is_n_zero() {
            return Ok(None);
        }
        if ! self.use_diff_from_mean_calculations {
            return Err(ValidationError::ProcedureNotProgrammedForState("May NOT be used with Sum of Xs Data.".to_string()));
        }
        self._add_up_xs_to_sums_of_powers(self.population,self.use_diff_from_mean_calculations)?;
        let unrounded: f64 = 
            match formula_id {
            2   => self.sums_of_powers_object.calculate_excess_kurtosis_2_jr_r()?,
            3   => self.sums_of_powers_object.generate_excess_kurtosis_3_365datascience()?,
            _   => {
                let m = "There is no excess kurtosis formula {formulaId} implemented at this time.".to_string();
                return Err(ValidationError::InvalidArgument(m));
            }
        };
        let rounded             = round_to_f64_precision(unrounded, self.out_precision);
        return Ok(Some(rounded));
    }

    pub fn request_kurtosis(&mut self) -> Result<Option<f64>, ValidationError> {
        if self.is_n_zero() {
            return Ok(None);
        }
        if ! self.use_diff_from_mean_calculations {
            return Err(ValidationError::ArgumentError("Sums of Xs not yet implemented.".to_string()));
        }
        self._add_up_xs_to_sums_of_powers(self.population,self.use_diff_from_mean_calculations)?;
        let unrounded   = self.sums_of_powers_object.request_kurtosis()?;
        let rounded     = round_to_f64_precision(unrounded, self.out_precision);
        return Ok(Some(rounded));
    }

    pub fn request_median(&mut self) -> Option<f64> {
        if self.is_n_zero() {
            return None;
        }
        let option = match self.calculate_quartile(2) {
            Ok(buffer) => buffer,
            Err(_err) => panic!("Cannot happen, practically."),
        };
        return option;
    }

    pub fn request_quartile_collection(&mut self) -> Result<Option<Vec<f64>>, ValidationError> {
        if self.is_n_zero() {
            return Ok(None);
        }
        let mut ra: Vec<f64> = Vec::new();
        for i in 0..5 {
            let option  = match self.calculate_quartile(i) {
                Ok(buffer)  => buffer,
                Err(_err)   => panic!("Cannot happen, practically."),
            };
            let b       = match option {
                None         => return Ok(None),
                Some(buffer) => buffer,
            };
            ra.push(b);
        }
        return Ok(Some(ra));
    }

    pub fn request_range(&mut self) -> Option<[f64;2]> {
        if self.is_n_zero() {
            return None;
        }
        let lmax = self.get_max()?;
        let lmin = self.get_min()?;
        return Some([lmin,lmax]);
    }

    pub fn request_result_aa_csv(&mut self) -> Result<Option<String>, ValidationError> {
        if self.is_n_zero() {
            return Ok(None);
        }
        let option          = self.request_summary_collection()?;
        let scaa            = match option {
            None            => return Ok(None),
            Some(aabuffer)  => aabuffer,
        };
        let b       = format!(  collection_csv_line_fmt_str!(),
                        Self::ARITHMETICMEANID,         scaa[&Self::ARITHMETICMEANID.to_string()],
                        Self::ARMEANAADID,              scaa[&Self::ARMEANAADID.to_string()],
                        Self::COVID,                    scaa[&Self::COVID.to_string()],
                        Self::GEOMETRICMEANID,          scaa[&Self::GEOMETRICMEANID.to_string()],
                        Self::HARMONICMEANID,           scaa[&Self::HARMONICMEANID.to_string()],
                        Self::ISEVENID,                 scaa[&Self::ISEVENID.to_string()],
                        Self::KURTOSISID,               scaa[&Self::KURTOSISID.to_string()],
                        Self::MAXID,                    scaa[&Self::MAXID.to_string()],
                        Self::MEDIANID,                 scaa[&Self::MEDIANID.to_string()],
                        Self::MEDIANAADID,              scaa[&Self::MEDIANAADID.to_string()],
                        Self::MINID,                    scaa[&Self::MINID.to_string()],
                        Self::MODEID,                   scaa[&Self::MODEID.to_string()],
                        Self::NID,                      scaa[&Self::NID.to_string()],
                        Self::SKEWNESSID,               scaa[&Self::SKEWNESSID.to_string()],
                        Self::STDDEVID,                 scaa[&Self::STDDEVID.to_string()],
                        Self::SUMID,                    scaa[&Self::SUMID.to_string()]);
        return Ok(Some(b));
    }

//345678901234567890123456789012345678901234567890123456789012345678901234567890
    pub fn request_result_csv_line(&mut self,include_hdr: bool) -> Result<Option<String>, ValidationError> {
        // NOTE: Mean Absolute Diffence is no longer featured here.
        if self.is_n_zero() {
            return Ok(None);
        }
        let option          = self.request_summary_collection()?;
        let scaa            = match option {
            None            => return Ok(None),
            Some(aabuffer)  => aabuffer,
        };
        let mut csvline         =
            format!(collection_csv_table_fmt_str!(),
                    scaa[&Self::ARITHMETICMEANID.to_string()],
                    scaa[&Self::ARMEANAADID.to_string()],
                    scaa[&Self::COVID.to_string()],
                    scaa[&Self::GEOMETRICMEANID.to_string()],
                    scaa[&Self::HARMONICMEANID.to_string()],
                    scaa[&Self::ISEVENID.to_string()],
                    scaa[&Self::KURTOSISID.to_string()],
                    scaa[&Self::MAXID.to_string()],
                    scaa[&Self::MEDIANID.to_string()],
                    scaa[&Self::MEDIANAADID.to_string()],
                    scaa[&Self::MINID.to_string()],
                    scaa[&Self::MODEID.to_string()],
                    scaa[&Self::NID.to_string()],
                    scaa[&Self::SKEWNESSID.to_string()],
                    scaa[&Self::STDDEVID.to_string()],
                    scaa[&Self::SUMID.to_string()]);
        if include_hdr {
            let csvhdr      =
                format!(collection_csv_table_fmt_str!(),
                        Self::ARITHMETICMEANID,
                        Self::ARMEANAADID,
                        Self::COVID,
                        Self::GEOMETRICMEANID,
                        Self::HARMONICMEANID,
                        Self::ISEVENID,
                        Self::KURTOSISID,
                        Self::MAXID,
                        Self::MEDIANID,
                        Self::MEDIANAADID,
                        Self::MINID,
                        Self::MODEID,
                        Self::NID,
                        Self::SKEWNESSID,
                        Self::STDDEVID,
                        Self::SUMID);
            csvline     = format!("{}\n{}\n",csvhdr,csvline);
        }
        return Ok(Some(csvline));
    }

    pub fn request_result_json(&mut self) -> Result<Option<String>, ValidationError> {
        if self.is_n_zero() {
            return Ok(None);
        }
        let option      = self.request_summary_collection()?;
        let scaa        = match option {
            None            => return Ok(None),
            Some(aabuffer)  => aabuffer,
        };
        let b       = format!(  collection_json_table_fmt_str!(),
                        Self::ARITHMETICMEANID,         scaa[&Self::ARITHMETICMEANID.to_string()],
                        Self::ARMEANAADID,              scaa[&Self::ARMEANAADID.to_string()],
                        Self::COVID,                    scaa[&Self::COVID.to_string()],
                        Self::GEOMETRICMEANID,          scaa[&Self::GEOMETRICMEANID.to_string()],
                        Self::HARMONICMEANID,           scaa[&Self::HARMONICMEANID.to_string()],
                        Self::ISEVENID,                 scaa[&Self::ISEVENID.to_string()],
                        Self::KURTOSISID,               scaa[&Self::KURTOSISID.to_string()],
                        Self::MAXID,                    scaa[&Self::MAXID.to_string()],
                        Self::MEDIANID,                 scaa[&Self::MEDIANID.to_string()],
                        Self::MEDIANAADID,              scaa[&Self::MEDIANAADID.to_string()],
                        Self::MINID,                    scaa[&Self::MINID.to_string()],
                        Self::MODEID,                   scaa[&Self::MODEID.to_string()],
                        Self::NID,                      scaa[&Self::NID.to_string()],
                        Self::SKEWNESSID,               scaa[&Self::SKEWNESSID.to_string()],
                        Self::STDDEVID,                 scaa[&Self::STDDEVID.to_string()],
                        Self::SUMID,                    scaa[&Self::SUMID.to_string()]);
        return Ok(Some(b));
    }

    pub fn request_skewness(&mut self,formula_id: u8) -> Result<Option<f64>, ValidationError> {
        if self.is_n_zero() {
            return Ok(None);
        }
        self._add_up_xs_to_sums_of_powers(self.population,self.use_diff_from_mean_calculations)?;
        let unrounded   = self.sums_of_powers_object.request_skewness(formula_id)?;
        let rounded     = round_to_f64_precision(unrounded, self.out_precision);
        return Ok(Some(rounded));
    }

    pub fn request_standard_deviation(&mut self) -> Result<Option<f64>, ValidationError> {
        if self.is_n_zero() {
            return Ok(None);
        }
        self._add_up_xs_to_sums_of_powers(self.population,self.use_diff_from_mean_calculations)?;
        let unrounded   = self.sums_of_powers_object.generate_standard_deviation()?;
        if unrounded == 0.0 {
            return Err(ValidationError::ValueMayNotBeZero(unrounded));
        }
        let stddev      = round_to_f64_precision(unrounded, self.out_precision);
        return Ok(Some(stddev));
    }

    pub fn request_summary_collection(&mut self) -> Result<Option<BTreeMap<String,String>>, ValidationError> {
        // NOTE:  Some of these are ONLY for sample.  For now, this is best used ONLY for Samples,
        // NOT populations numbers.
        // NOTE:  BTreeMap usage was adopted to yield ordered output.  Other options may be reviewed
        // later.
        if self.is_n_zero() {
            return Ok(None);
        }
        let mut btmb: BTreeMap<String,String>   = BTreeMap::new();
        self._add_up_xs_to_sums_of_powers(self.population,self.use_diff_from_mean_calculations)?;
        insert_op_data_to_aa(self.calculate_arithmetic_mean(),              &mut btmb,  Self::ARITHMETICMEANID);
        insert_op_data_to_aa(self.calculate_geometric_mean(),               &mut btmb,  Self::GEOMETRICMEANID);
        insert_op_data_to_aa(self.calculate_harmonic_mean()?,               &mut btmb,  Self::HARMONICMEANID);
        insert_op_data_to_aa(Some(self.calculate_sum()),                    &mut btmb,  Self::SUMID);
        insert_op_data_to_aa(self.generate_average_absolute_deviation(Self::ARITHMETICMEANID)?,
                                                                                &mut btmb,  Self::ARMEANAADID);
        insert_op_data_to_aa(self.generate_average_absolute_deviation(Self::MEDIANID)?,
                                                                                &mut btmb,  Self::MEDIANAADID);
        insert_op_data_to_aa(self.generate_coefficient_of_variation()?,     &mut btmb,  Self::COVID);
        insert_op_data_to_aa(self.generate_mean_absolute_difference()?,     &mut btmb,  Self::MADID);
        insert_op_data_to_aa(self.generate_mode(),                          &mut btmb,  Self::MODEID);
        insert_op_data_to_aa(Some(self.get_count() as f64),                 &mut btmb,  Self::NID);
        insert_op_data_to_aa(self.get_max(),                                &mut btmb,  Self::MAXID);
        insert_op_data_to_aa(self.get_min(),                                &mut btmb,  Self::MINID);
        if self.is_n_even() {
            btmb.insert(Self::ISEVENID.to_string(),"TRUE".to_string());
        } else {
            btmb.insert(Self::ISEVENID.to_string(),"FALSE".to_string());
        }
        insert_op_data_to_aa(self.request_kurtosis()?,                      &mut btmb,  Self::KURTOSISID);
        insert_op_data_to_aa(self.request_median(),                         &mut btmb,  Self::MEDIANID);
        insert_op_data_to_aa(self.request_skewness(3)?,                     &mut btmb,  Self::SKEWNESSID);
        insert_op_data_to_aa(self.request_standard_deviation()?,            &mut btmb,  Self::STDDEVID);
        return Ok(Some(btmb));
    }

    pub fn request_variance_sum_of_differences_from_mean(&mut self,population_calculation: bool) -> Result<Option<f64>, ValidationError> {
        if self.is_n_zero() {
            return Ok(None);
        }
        self._add_up_xs_to_sums_of_powers(population_calculation,true)?;
        let v = self.sums_of_powers_object.calculate_variance_using_subject_as_diffs()?;
        // Note rounding is not done here, as it would be double rounded with stddev.
        return Ok(Some(v));
    }

    pub fn request_variance_sum_of_xs_squared_method(&mut self,population_calculation: bool) -> Result<Option<f64>, ValidationError> {
        if self.is_n_zero() {
            return Ok(None);
        }
        self._add_up_xs_to_sums_of_powers(population_calculation,false)?;
        let v = self.sums_of_powers_object.calculate_variance_using_subject_as_sum_xs()?;
        // Note rounding is not done here, as it would be double rounded with stddev.
        return Ok(Some(v));
    }

}

//345678901234567890123456789012345678901234567890123456789012345678901234567890
//345678901234567890123456789012345678901234567890123456789012345678901234567890
// VectorOfDiscrete - catchall for arbitrary X that could be a string.

pub struct VectorOfDiscrete {
    in_precision: i32,
    out_precision: i32,
    frequencies_aa: BTreeMap<String,u32>,
    vector_of_x: Vec<String>,
}

pub fn init_vector_of_discrete() -> VectorOfDiscrete {
    VectorOfDiscrete {
        in_precision: -1,
        out_precision: 4,
        frequencies_aa: BTreeMap::new(),
        vector_of_x: Vec::new(),
    }
}

impl VectorOfX for VectorOfDiscrete {

    fn get_count(&self) -> usize {
        let n = self.vector_of_x.len();
        return n;
    }

    fn get_in_precision(&self) -> i32 {
        return -1;
    }

    fn get_out_precision(&self) -> i32 {
        return self.out_precision;
    }

    fn get_vector_of_strings(&self) -> Option<Vec<String>> {
        if self.is_n_zero() {
            return None;
        }
        return Some(self.vector_of_x.to_owned());
    }

    fn is_n_even(&self) -> bool {
        let n = self.get_count();
        if n % 2 == 0 {
            return true
        }
        return false;
    }

    fn is_n_zero(&self) -> bool {
        if self.get_count() == 0 {
            return true;
        }
        return false;
    }

    fn load_from_str_vector(&mut self,vector_of_x: Vec<&str>,on_bad_data: BadDataAction) -> Result<(),ValidationError> {
        for lx in vector_of_x.iter() {
            self.push_x_string(lx.to_string(),on_bad_data)?;
        }
        return Ok(());
    }

    fn load_from_string_vector(&mut self,vector_of_x: Vec<String>,on_bad_data: BadDataAction) -> Result<(),ValidationError> {
        for lx in vector_of_x.iter() {
            self.push_x_string(lx.to_string(),on_bad_data)?;
        }
        return Ok(());
    }

    fn push_x_str(&mut self,x_item: &str,on_bad_data: BadDataAction) -> Result<(), ValidationError> {
        self.push_x_string(x_item.to_string(),on_bad_data)?;
        return Ok(());
    }

    fn push_x_string(&mut self,x_item: String,on_bad_data: BadDataAction) -> Result<(), ValidationError> {
        let mut x_mut   = x_item.to_string();
        if x_mut.len() == 0 {
            match on_bad_data {
                BLANKFIELD   => x_mut=" ".to_string(),
                DEFAULTFILL  => x_mut=" ".to_string(),
                EXCLUDEROW   => return Err(ValidationError::OptionMayNotBeUsedHere("ExcludeRow".to_string())),
                FAIL            => return Err(ValidationError::ValueMayNotBeMissing()),
                SKIPDATAITEM => return Ok(()),
                ZEROFLOAT    => x_mut="0.0".to_string(),
                ZEROINTEGER  => x_mut="0".to_string(),
                _               => panic!("Should never happen.  Programmer error."),
            };
        }
        self.vector_of_x.push(x_mut.to_string());
        match self.frequencies_aa.get(&x_mut) {
            Some(b) => self.frequencies_aa.insert(x_mut.to_string(),b + 1),
            None    => self.frequencies_aa.insert(x_mut.to_string(),1),
        };
        return Ok(());
    }

}

impl VectorOfDiscrete {

    const FREQUENCYPREFIXID:    &str  = "FreqPrefix";
    const ISEVENID:             &str  = "IsEven";
    const MODEID:               &str  = "Mode";
    const NID:                  &str  = "N";

    fn _refill_frequencies_btree(&mut self) -> Result<(), ValidationError> {
        self.frequencies_aa.clear();
        for lx in self.vector_of_x.iter() {
            match self.frequencies_aa.get(lx) {
                Some(b) => self.frequencies_aa.insert(lx.to_string(),b + 1),
                None    => self.frequencies_aa.insert(lx.to_string(),1),
            };
        }
        return Ok(());
    }

    pub fn calculate_binomial_probability(&self,subject_value: String,n_trials: u32,n_successes: u32) -> Result<Option<f64>, ValidationError> {
        if self.is_n_zero() {
            return Ok(None);
        }
        if n_trials > 170 {
            return Err(ValidationError::ArgumentError("Value may not be larger than 170.".to_string()));
        }
        if n_trials == 0 {
            return Err(ValidationError::ValueMayNotBeZero(n_trials as f64));
        }
        if n_successes == 0 {
            return Err(ValidationError::ValueMayNotBeZero(n_successes as f64));
        }
        if n_trials <= n_successes {
            let m = "Number of Successes ({n_successes}) must be less than number of trials ({n_trials}).".to_string();
            return Err(ValidationError::ArgumentError(m));
        }
        let n_failures                  = n_trials - n_successes;

        let samplecountf                = self.get_count() as f64;

        let frequency                   = match self.frequencies_aa.get(&subject_value) {
            Some(b)                 => b,
            None                    => return Ok(Some(0.0)),
        };
        let freqcountf                  = *frequency as f64;

        let psuccess1trial              = freqcountf / samplecountf; // Probability of success in 1 trial.

        let pfailure1trial              = 1.0 - psuccess1trial;

        let pfailurefactor              = pfailure1trial.powi(n_failures as i32);
        let psuccessfactor              = psuccess1trial.powi(n_successes as i32);

        let combinations: f64;
        if n_trials > 34 {
            let successpermutations     = factorial(n_successes as u128);
            let failurepermutations     = factorial(n_trials as u128 - n_successes as u128);
            let trials_permutations     = factorial(n_trials as u128);

            if successpermutations < failurepermutations {
                let b                   = trials_permutations / failurepermutations;
                combinations            = b as f64 / successpermutations as f64; 
                
            } else {
                let b                   = trials_permutations / successpermutations;
                combinations            = b as f64 / failurepermutations as f64; 
            }
        } else {
            let successpermutations     = ffactorial(n_successes as u8);
            let failurepermutations     = ffactorial(n_trials as u8 - n_successes as u8);
            let trials_permutations     = ffactorial(n_trials as u8);
            combinations                = trials_permutations / ( successpermutations * failurepermutations )
        }
        let binomialprobability         = combinations * psuccessfactor * pfailurefactor;
        return Ok(Some(binomialprobability));
    }

    pub fn get_frequency(&self,subject_value: String) -> Option<u32> {
        if self.is_n_zero() {
            return None;
        }
        let frequency = match self.frequencies_aa.get(&subject_value) {
            Some(b) => *b,
            None    => return None,
        };
        return Some(frequency);
    }

    pub fn get_x(&mut self,index_a: usize) -> Option<String> {
        let n = self.get_count();
        if n <= index_a {
            return None;
        }
        return Some(self.vector_of_x[index_a].clone());
    }

    pub fn request_mode(&self) -> Option<String> {
        if self.is_n_zero() {
            return None;
        }
        let option = generate_mode_from_frequency_aa(&self.frequencies_aa);
        return option;
    }

    pub fn request_result_aa_csv(&self) -> Option<String> {
        if self.is_n_zero() {
            return None;
        }
        let mut content         = "ID,Value".to_string();
        let option              = self.request_summary_collection();
        let resultcollection    = match option {
            None            => return None,
            Some(aabuffer)  => aabuffer,
        };
        //for (idstr, &valstring) in resultcollection {
        for (idstr, valstring) in resultcollection.iter() {
            content = format!("{content}\n{idstr},{valstring}");
        }
        content = format!("{content}\n");
        return Some(content);
    }

    pub fn request_result_csv_line(&self) -> Option<String> {
        if self.is_n_zero() {
            return None;
        }
        let mut content         = "".to_string();
        let option              = self.request_summary_collection();
        let resultcollection    = match option {
            None            => return None,
            Some(aabuffer)  => aabuffer,
        };
        for (idstr, valstring) in resultcollection.iter() {
            content = format!("{content},{idstr},{valstring}");
        }
        content = format!("{content}\n");
        return Some(content);
    }

    pub fn request_result_json(&self)  -> Option<String> {
        if self.is_n_zero() {
            return None;
        }
        let mut content         = "{{".to_string();
        let mut i               = 0;
        let option              = self.request_summary_collection();
        let resultcollection    = match option {
            None            => return None,
            Some(aabuffer)  => aabuffer,
        };
        for (idstr, valstring) in resultcollection.iter() {
            if i == 0 {
                content = format!("{content}\n\"{idstr}\": \"{valstring}\"");
            } else {
                content = format!("{content},\n\"{idstr}\": \"{valstring}\"");
            }
            i += 1;
        }
        content = format!("{content}\n}}");
        return Some(content);
    }

    pub fn request_summary_collection(&self) -> Option<BTreeMap<String,String>> {
        if self.is_n_zero() {
            return None;
        }
        let mut btmb: BTreeMap<String,String>   = BTreeMap::new();
        for (lx, &count) in &self.frequencies_aa {
            let freqid                          = format!("{}_{}",Self::FREQUENCYPREFIXID,lx);
            btmb.insert(freqid,format!("{count}"));
        }
        let count                               = self.get_count();
        btmb.insert(Self::NID.to_string(),format!("{count}"));
        if self.is_n_even() {
            btmb.insert(Self::ISEVENID.to_string(),"TRUE".to_string());
        } else {
            btmb.insert(Self::ISEVENID.to_string(),"FALSE".to_string());
        }
        let lmode                               = match self.request_mode() {
            None        => "None".to_string(),
            Some(b)     => b,
        };
        btmb.insert(Self::MODEID.to_string(),format!("{lmode}"));
        return Some(btmb);
    }
}

//345678901234567890123456789012345678901234567890123456789012345678901234567890
//345678901234567890123456789012345678901234567890123456789012345678901234567890
// VectorTable for reading and processing contents of 2 dimentional matrices.
// NOTE:  Indexing for columns and vectors in this class are reversed from
// normal in accommodation of the way things are used.

pub enum VectorClassId {
    VOCID,
    VODID,
}

pub struct VectorTable { 
    table_of_vectors:   Vec<Box<dyn VectorOfX>>,          // Columns in the CSV input sense.
    vector_count:       usize,                      // My terms are transposed from the orientation of the CSV file.  You'll see I call these columns.
    vector_of_classes:  Vec<VectorClassId>,
    vector_of_headers:  Vec<String>,
    vector_length:      usize,                      // Rows in the CSV input sense.
}

impl Default for VectorTable {
    fn default() -> Self {
        VectorTable {
            table_of_vectors:   Vec::new(),
            vector_of_classes:  Vec::new(),
            vector_of_headers:  Vec::new(),
            vector_count:       0,
            vector_length:      0,
        }
    }
}

impl VectorTable {

    fn _parse_csv_string(data_string: String) -> Option<Vec<String>> {
        if data_string.len() == 0 {
            return None;
        }
        let mut dsb = data_string.to_string();
        let trimbeginquote  = Regex::new(r#"^""#).unwrap();
        let trimendquote    = Regex::new(r#""$"#).unwrap();
        if trimbeginquote.is_match(dsb.as_str()) {
            dsb = dsb[1..dsb.len()].to_string();
        }
        if trimendquote.is_match(data_string.as_str()) {
            dsb = dsb[0..dsb.len()-1].to_string();
        }
        let seperator   = Regex::new(r#""?,"?"#).expect("Invalid regex");
        let result: Vec<String> = seperator.split(dsb.as_str()).map(|s| s.to_string()).collect();

        Some(result)
    }

    fn _skip_indicated(on_bad_data: BadDataAction,ll: String) -> bool {
        match on_bad_data {
            EXCLUDEROW  => {
                let re = Regex::new(r",,").unwrap();
                let sstr = ll.trim();
                if re.is_match(sstr) {
                    return true;
                };
            },
            _                           => return false,
        }
        return false;
    }

    pub fn array_of_char_2_vector_of_classes(a_a: Vec<&str>) -> Result<Vec<VectorClassId>,ValidationError> {
        let mut oa: Vec<VectorClassId> = Vec::new();
        for lc in a_a.iter() {
            match *lc {
                "C" => oa.push(VectorClassId::VOCID),
                "D" => oa.push(VectorClassId::VODID),
                _   => {
                    let m = "Identifier '{lc}' is not recognized.  Allowed identifier characters are {{C,D}}.";
                    return Err(ValidationError::ArgumentError(m.to_string()));
                },
            }
        }
        return Ok(oa);
    }

    pub fn array_of_class_labels_2_vector_of_classes(a_a: Vec<&str>) -> Result<Vec<VectorClassId>,ValidationError> {
        let mut oa: Vec<VectorClassId> = Vec::new();
        for llabel in a_a.iter() {
            match *llabel {
                "VectorOfContinuous"    => oa.push(VectorClassId::VOCID),
                "VectorOfDiscrete"      => oa.push(VectorClassId::VODID),
                _   => {
                    let m = "'#{llabel}' is Invalid. Allowed are: {{VectorOfContinuous,VectorOfDiscrete}}.";
                    return Err(ValidationError::ArgumentError(m.to_string()));
                },
            }
        }
        return Ok(oa);
    }

    pub fn get_column_count(&self) -> usize {
        return self.vector_count;
    }

    pub fn get_row_count(&self) -> usize {
        // As of 2023/11/14 I have put little thought into regular data, and hope simple
        // validations will keep it away for now.
        return self.vector_length;
    }

    pub fn get_vector_of_continuous_object(&self,index_no: usize) -> Result<VectorOfContinuous,ValidationError> {
        if self.vector_count <= index_no {
            return Err(ValidationError::InvalidIndex(index_no,0,self.vector_count-1));
        }
        let vosb: Vec<String>   = match self.table_of_vectors[index_no].get_vector_of_strings() {
            Some(b)     => b,
            None        => Vec::new(),
        };
        let vofb: Vec<f64>      = match get_vector_of_f64_from_strings(&vosb) {
            Ok(b)       => b,
            Err(_err)   => return Err(ValidationError::InvalidVectorObject(index_no,"VectorOfContinuous".to_string())),
        };
        if self.table_of_vectors[index_no].get_implementation_name() == "statistics1v::VectorOfContinuous" {
            let b = VectorOfContinuous {
                in_precision:                               self.table_of_vectors[index_no].get_in_precision(),
                out_precision:                              self.table_of_vectors[index_no].get_out_precision(),
                population:                                 false,
                sorted_vector_of_x:                         Vec::new(),
                sums_of_powers_object: SumsOfPowers::new(   false),
                use_diff_from_mean_calculations:            false,
                validate_string_numbers:                    false,
                vector_of_x:                                vofb,
            };
            return Ok(b);
        } else {
            return Err(ValidationError::InvalidVectorObject(index_no,"VectorOfContinuous".to_string()));
        }
    }

    pub fn get_vector_of_discrete_object(&self,index_no: usize) -> Result<VectorOfDiscrete,ValidationError> {
        if self.vector_count <= index_no {
            return Err(ValidationError::InvalidIndex(index_no,0,self.vector_count-1));
        }
        let vosb: Vec<String>   = match self.table_of_vectors[index_no].get_vector_of_strings() {
            Some(b)     => b,
            None        => Vec::new(),
        };
        if self.table_of_vectors[index_no].get_implementation_name() == "statistics1v::VectorOfDiscrete" {
            let mut b = VectorOfDiscrete {
                in_precision:                               self.table_of_vectors[index_no].get_in_precision(),
                out_precision:                              self.table_of_vectors[index_no].get_out_precision(),
                frequencies_aa:                             BTreeMap::new(),
                vector_of_x:                                vosb,
            };
            b._refill_frequencies_btree()?;
            return Ok(b);
        } else {
            return Err(ValidationError::InvalidVectorObject(index_no,"VectorOfContinuous".to_string()));
        }
    }

    pub fn new_from_csv(vc_spec: Vec<VectorClassId>,f_spec: &str,on_bad_data: BadDataAction,see_first_line_as_header: bool) -> Result<Option<VectorTable>,ValidationError> {
        let mut localo = VectorTable::new(vc_spec);
        let mut i = 0;
        for llresult in read_to_string(f_spec).unwrap().lines() {
            if llresult.len() > 0 {
                let llst = llresult.trim().to_string();
                if VectorTable::_skip_indicated(on_bad_data,llst.to_string()) {
                    continue;
                }
                if ( i == 0 ) {
                    if see_first_line_as_header {
                        if let Some(hv) = VectorTable::_parse_csv_string(llst) {
                            localo.use_array_for_column_identifiers(hv)?;
                            i += 1;
                            continue;
                        } else {
                            return Ok(None);
                        }
                    }
                }
                if let Some(dv) = VectorTable::_parse_csv_string(llst) {
                    localo.push_table_row(dv,on_bad_data)?;
                    i += 1;
                }
            }
        }
        return Ok(Some(localo));
    }

    pub fn new(vector_of_classes: Vec<VectorClassId>) -> Self {
        let mut buffer: VectorTable = Default::default();
        let mut i = 0;
        buffer.vector_of_classes    = vector_of_classes;
        for lci in buffer.vector_of_classes.iter() {
            match lci {
                VectorClassId::VOCID    => {
                        let b = init_vector_of_continuous();
                        buffer.table_of_vectors.push(Box::new(b));
                        println!("vector {i} is a VOC.");
                    },
                VectorClassId::VODID    => {
                        let b = init_vector_of_discrete();
                        buffer.table_of_vectors.push(Box::new(b));
                        println!("vector {i} is a VOD.");
                    },
            };
            buffer.vector_of_headers.push("Column {i}".to_string()); // Use offset index as column numbers, NOT traditional.
            i                       += 1;
        }
        buffer.vector_count         = i;
        return buffer;
    }

    /*
    // This can be done it appears, but it's low priority.  Do it in the naive draft. NOTE:TBD202312192224
    fn each_column_vector(&self) {
        self.table_of_vectors.each do |lvo|
            yield lvo
        }
    }
     */

    pub fn push_table_row(&mut self,array_a: Vec<String>,on_bad_data: BadDataAction) -> Result<(),ValidationError> {
        let alen    = array_a.len();
        let tlen    = self.table_of_vectors.len();
        if alen != tlen {
            return Err(ValidationError::VectorPairLengthsNotEqual(alen,tlen));
        }
        match on_bad_data {
            SKIPDATAITEM => {
                    let m = "Skip Action Not Allowed within VectorTable.";
                    return Err(ValidationError::ArgumentError(m.to_string()));
                },
            _                           => (),
        }
        let mut i = 0;
        for ltovo in self.table_of_vectors.iter_mut() {
            ltovo.push_x_string(array_a[i].to_owned(),on_bad_data)?;
            i += 1;
        }
        self.vector_length += 1;
        return Ok(());
    }

    pub fn use_array_for_column_identifiers(&mut self,hdr_columns: Vec<String>) -> Result<(),ValidationError> {
        let alen    = hdr_columns.len();
        let hlen    = self.vector_of_headers.len();
        if alen != hlen {
            return Err(ValidationError::VectorPairLengthsNotEqual(alen,hlen));
        }
        // May Need to transform from one kind of string to another. xc NOTE:TBD
        let mut i = 0;
        for lc in hdr_columns.iter() {
            self.vector_of_headers[i] = lc.to_string();
            i += 1;
        }
        return Ok(());
    }

}

//345678901234567890123456789012345678901234567890123456789012345678901234567890
//345678901234567890123456789012345678901234567890123456789012345678901234567890
// Unit Tests
//345678901234567890123456789012345678901234567890123456789012345678901234567890
//345678901234567890123456789012345678901234567890123456789012345678901234567890

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
    fn test_factorial() {
        let m   = factorial(5);
        assert_eq!(120, m);
        let m   = factorial(25);
        assert_eq!(15511210043330985984000000, m);
        let m   = factorial(32);
        assert_eq!(263130836933693530167218012160000000, m);
        let m   = factorial(33);
        assert_eq!(8683317618811886495518194401280000000, m);
        let m   = factorial(34); // This appears to be the max on my Ubuntu laptop.
        assert_eq!(295232799039604140847618609643520000000, m);
    }

    #[test]
    fn test_ffactorial() {
        let m   = ffactorial(5);
        assert_eq!(120.0, m);
        let m   = ffactorial(25);
        assert_eq!(15511210043330985984000000.0, m);
        let m   = ffactorial(32);
        assert_eq!(263130836933693530167218012160000000.0, m);
        let m   = ffactorial(64);
        assert_eq!(1.2688693218588417e89, m);
        let m   = ffactorial(128);
        assert_eq!(3.8562048236258025e215, m);
        let m   = ffactorial(164);
        assert_eq!(3.2872185855342945e293, m);
        let m   = ffactorial(169);
        assert_eq!(4.2690680090047027e304, m);
        let m   = ffactorial(170); // This appears to be the max on my Ubuntu laptop.
        assert_eq!(7.257415615307994e306, m);
    }

    #[test]
    fn test_anecdote_expected_results() {
        let d: BTreeMap<String, u32>    = BTreeMap::from([("1234".to_string(), 528), ("528".to_string(), 3), ("A longer string".to_string(), 0), ("x".to_string(), 55555)]);
        let result                      = match generate_mode_from_frequency_aa(&d) {
            None            => panic!("Test failed."),
            Some(buffer)    => buffer,
        };
        let cmpstring                   = "x".to_string();
        assert_eq!(cmpstring, result);
    }

    #[test]
    fn test_from_f64_to_i128() {
        let b = from_f64_to_i128(4,1234.56789);
        assert_eq!(12345679,b);
    }

    #[test]
    fn test_from_i128_to_f64() {
        let b = from_i128_to_f64(4,12345679);
        assert_eq!(1234.5679,b);
    }

    #[test]
    fn test_get_vector_of_f64_from_strings() {
        //let b = get_vector_of_f64_from_strings(v_a: &Vec<String>) -> Result<Vec<f64>,ValidationError> {
        let a   = vec!["1".to_string(),"2".to_string(),"3".to_string()];
        let b   = get_vector_of_f64_from_strings(&a).unwrap();
        assert_eq!(1.0,b[0]);
        assert_eq!(2.0,b[1]);
        assert_eq!(3.0,b[2]);
    }

    #[test]
    fn test_insert_op_data_to_aa() {
        let mut btmo: BTreeMap<String,String>    = BTreeMap::new();
        const BID: &str  = "BoinkId";
        insert_op_data_to_aa(Some(125.521),&mut btmo,BID);
        let idb = BID.to_string();
        match btmo.get(&idb) {
            None    => panic!("Test failed."),
            Some(b) => assert_eq!(*b,"125.521".to_string()),
        }
    }

    #[test]
    fn test_is_a_num_str() {
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
    fn test_is_usable_number_str_array() {
        assert!(is_usable_number_str_array(&["1","33.33","4"]));
        assert!(!is_usable_number_str_array(&["1"," 2 3 5 "]));
        assert!(!is_usable_number_str_array(&["1s","235"]));
        assert!(!is_usable_number_str_array(&[".","235"]));
        assert!(!is_usable_number_str_array(&["","235"]));
        assert!(is_usable_number_str_array(&["235"]));
    }

    #[test]
    fn test_is_usable_number_string_array() {
        assert!(is_usable_number_string_array(&["1".to_string(),"33.33".to_string(),"4".to_string()]));
        assert!(!is_usable_number_string_array(&["1".to_string()," 2 3 5 ".to_string()]));
    }

    #[test]
    fn test_is_usable_number_str_vector() {
        assert!(is_usable_number_str_vector(&vec!["1","33.33","4"]));
        assert!(!is_usable_number_str_vector(&vec!["1"," 2 3 5 "]));
        assert!(!is_usable_number_str_vector(&vec!["1s","235"]));
        assert!(!is_usable_number_str_vector(&vec![".","235"]));
        assert!(!is_usable_number_str_vector(&vec!["","235"]));
        assert!(is_usable_number_str_vector(&vec!["235"]));
    }

    #[test]
    fn test_is_usable_number_string_vector() {
        assert!(is_usable_number_string_vector(&vec!["1".to_string(),"33.33".to_string(),"4".to_string()]));
        assert!(!is_usable_number_string_vector(&vec!["1".to_string()," 2 3 5 ".to_string()]));
        assert!(!is_usable_number_string_vector(&vec!["1s".to_string(),"235".to_string()]));
        assert!(!is_usable_number_string_vector(&vec![".".to_string(),"235".to_string()]));
        assert!(!is_usable_number_string_vector(&vec!["".to_string(),"235".to_string()]));
        assert!(is_usable_number_string_vector(&vec!["235".to_string()]));
    }

    #[test]
    fn test_parse_float_left_of_decimal() {
    //pub fn parse_float_left_of_decimal(subject_float: f64) -> f64 
        let bf  = parse_float_left_of_decimal(1234.56789);
        assert_eq!(bf,1234.0);
    }

    #[test]
    fn test_parse_float_right_of_decimal() {
    //pub fn parse_float_right_of_decimal(subject_float: f64,precision: i32) -> f64 
        let bf  = parse_float_right_of_decimal(1234.56789,5);
        assert_eq!(bf,0.56789);
        let bf  = parse_float_right_of_decimal(1234.56789,2);
        assert_eq!(bf,0.57);
    }

    #[test]
    fn test_push_i128_from_f64() {
    //pub fn push_i128_from_f64(precision: i32,subject_float: f64, sorting_vector: &mut Vec<i128>) {
        let mut sv: Vec<i128>   = Vec::new();
        push_i128_from_f64(4,123.456, &mut sv);
        assert_eq!(1,sv.len());
        push_i128_from_f64(4,999.88, &mut sv);
        push_i128_from_f64(1,12345.6789, &mut sv);
        assert_eq!(3,sv.len());
        assert_eq!(1234560,sv[0]);
        assert_eq!(9998800,sv[1]);
        assert_eq!(123457,sv[2]);
    }

    #[test]
    fn test_round_to_f64_precision() {
        assert_eq!(round_to_f64_precision(1234.56789123457890, 4),1234.5679);
        assert_eq!(round_to_f64_precision(1234.0, 4),1234.0);
    }

    #[test]
    fn test_zero_decimal_effective() {
        assert!(zero_decimal_effective(1,1.0001));
        assert!(!zero_decimal_effective(1,1.1001));
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

    #[test]
    fn test_construct_histogramofx_basic_construction() {
        let hoxo: HistogramOfX = Default::default();
        assert_eq!(hoxo.max,0.0);
        assert_eq!(hoxo.min,0.0);
        let resulto: Result<HistogramOfX,ValidationError> = HistogramOfX::new(0.0,99.99);
        let hoxo: HistogramOfX = match resulto {
            Ok(hoxo) => hoxo,
            Err(_err) => panic!("PASSing test will not get here."),
        };
        assert_eq!(hoxo.max,99.99);
        assert_eq!(hoxo.min,0.0);
    }

    #[test]
    fn test_construct_histogramofx_construction_by_segment_count() {
    
        let resulto: Result<HistogramOfX,ValidationError> = HistogramOfX::new_from_uniform_segment_size(0.0,999.0,256.0);
        let hoxo: HistogramOfX = match resulto {
            Ok(hoxo) => hoxo,
            Err(_err) => panic!("PASSing test will not get here."),
        };
        assert_eq!(hoxo.max,999.0);
        assert_eq!(hoxo.min,0.0);
    }

    #[test]
    fn test_construct_histogramofx_construction_by_segment_size() {
        let resulto: Result<HistogramOfX,ValidationError> = HistogramOfX::new_from_desired_segment_count(0.0,999.0,6,5.999);
        let hoxo: HistogramOfX = match resulto {
            Ok(hoxo) => hoxo,
            Err(_err) => panic!("PASSing test will not get here."),
        };
        assert_eq!(hoxo.max,999.0);
        assert_eq!(hoxo.min,0.0);
    }

    #[test]
    fn test_construct_a_histogram_dataset_and_return_data() {
        let resulto: Result<HistogramOfX,ValidationError> = HistogramOfX::new_from_desired_segment_count(0.0,999.0,3,0.0);
        let mut hoxo: HistogramOfX = match resulto {
            Ok(hoxo) => hoxo,
            Err(_err) => panic!("PASSing test will not get here."),
        };
        hoxo.add_to_counts(125.6).unwrap();
        hoxo.add_to_counts(250.7).unwrap();
        hoxo.add_to_counts(375.8).unwrap();
        hoxo.add_to_counts(500.9).unwrap();
        hoxo.add_to_counts(626.0).unwrap();
        hoxo.add_to_counts(751.1).unwrap();
        hoxo.add_to_counts(876.2).unwrap();
        hoxo.add_to_counts(909.09).unwrap();
        hoxo.add_to_counts(808.08).unwrap();
        hoxo.add_to_counts(707.07).unwrap();
        hoxo.add_to_counts(606.06).unwrap();
        hoxo.add_to_counts(505.05).unwrap();
        hoxo.add_to_counts(404.04).unwrap();
        hoxo.add_to_counts(303.03).unwrap();
        hoxo.add_to_counts(202.02).unwrap();
        hoxo.add_to_counts(101.01).unwrap();
        hoxo.add_to_counts(0.00).unwrap();
        let dataset: Vec<(f64,f64,usize)> = hoxo.generate_count_collection();
        assert_eq!(dataset.len(), 3);
    }

    #[test]
    fn test_simple_construction() {
        let resulto: Result<HistogramOfX,ValidationError> = HistogramOfX::new(1.0,3.0);
        let mut localo: HistogramOfX = match resulto {
            Ok(localo) => localo,
            Err(_err) => panic!("PASSing test will not get here."),
        };
        localo.set_occurrence_range(1.0,3.0).unwrap();
        localo.set_occurrence_range(3.0,6.0).unwrap();
        localo.add_to_counts(1.0).unwrap();
        localo.add_to_counts(1.0).unwrap();
        localo.add_to_counts(2.0).unwrap();
        localo.add_to_counts(3.0).unwrap();
        localo.add_to_counts(3.0).unwrap();
        localo.add_to_counts(3.0).unwrap();
        let result = localo.generate_count_collection();
        let rtuple = result[0];
        assert_eq!(rtuple.0, 1.0);
        assert_eq!(rtuple.1, 3.0);
        assert_eq!(rtuple.2, 3);
        let rtuple = result[1];
        assert_eq!(rtuple.0, 3.0);
        assert_eq!(rtuple.1, 6.0);
        assert_eq!(rtuple.2, 3);
    }

    #[test]
    fn test_construction_by_segment_size() {
        let mut localo = HistogramOfX::new_from_uniform_segment_size(1.0,5.0,3.0).unwrap();
        localo.add_to_counts(1.0).unwrap();
        localo.add_to_counts(1.0).unwrap();
        localo.add_to_counts(2.0).unwrap();
        localo.add_to_counts(3.0).unwrap();
        localo.add_to_counts(3.0).unwrap();
        localo.add_to_counts(3.0).unwrap();
        let result = localo.generate_count_collection();
        assert_eq!(result[0].0, 1.0);
        assert_eq!(result[0].1, 4.0);
        assert_eq!(result[0].2, 6);
        assert_eq!(result[1].0, 4.0);
        assert_eq!(result[1].1, 7.0);
        assert_eq!(result[1].2, 0);
    }

    #[test]
    fn test_construction_by_number_of_segments() {
        let mut localo = HistogramOfX::new_from_desired_segment_count(1.0,5.0,2,0.0).unwrap();
        localo.add_to_counts(1.0).unwrap();
        localo.add_to_counts(1.0).unwrap();
        localo.add_to_counts(2.0).unwrap();
        localo.add_to_counts(3.0).unwrap();
        localo.add_to_counts(3.0).unwrap();
        localo.add_to_counts(3.0).unwrap();
        let result = localo.generate_count_collection();
        assert_eq!(result[0].0, 1.0);
        assert_eq!(result[0].1, 3.5);
        assert_eq!(result[0].2, 6);
        assert_eq!(result[1].0, 3.5);
        assert_eq!(result[1].1, 6.0);
        assert_eq!(result[1].2, 0);
    }

    #[test]
    fn test_internal_class_rangeoccurrence() {
        // Note, this is out of theme in "sames" compliance to the fact that
        // in other implementations it is a sub-class to HistogramOfX.
        let mut localo = RangeOccurrence::new(1.0,2.0);
        assert!( localo.has_overlap(1.0,2.0) );
        assert!( ! localo.has_overlap(2.0,3.0) );
        assert_eq!(0, localo.count);
        assert_eq!(1.0, localo.start_no);
        assert_eq!(2.0, localo.stop_no);
        localo.add_to_count();
        assert_eq!(1, localo.count);
        assert!( localo.is_in_range(1.0) );
        assert!( localo.is_in_range(1.5) );
        assert!( ! localo.is_in_range(2.0));
    }

    #[test]
    fn test_internal_validation_against_overlapping_ranges() {
        let mut localo = HistogramOfX::new(-128.0,128.0).unwrap();
        localo.set_occurrence_range(-128.0,-64.0).unwrap();
        localo.set_occurrence_range(-64.0,0.0).unwrap();
        localo.set_occurrence_range(0.0,64.0).unwrap();
        localo.set_occurrence_range(64.0,129.0).unwrap();
        let resulto: Result<(),ValidationError> = localo.set_occurrence_range(25.0,99.0);
        match resulto {
            Ok(()) =>panic!("Ok should not occur, so it fails this test."), 
            Err(_err) => true,
        };
    }

    #[test]
    fn test_adding_to_counts() {
        let mut localo = HistogramOfX::new(-5.0,0.0).unwrap();
        localo.set_occurrence_range(0.0,5.0).unwrap();
        localo.add_to_counts(1.0).unwrap();
        localo.add_to_counts(2.0).unwrap();
        localo.add_to_counts(-3.0).unwrap();
        let resulto: Result<(),ValidationError> = localo.add_to_counts(8.0);
        match resulto {
            Ok(()) =>panic!("Ok should not occur, so it fails this test."), 
            Err(_err) => true,
        };
    }

    #[test]
    fn test_generating_an_ordered_list_of_vectors_of_counts() {
        let mut localo = HistogramOfX::new(-128.0,128.0).unwrap();
        localo.set_occurrence_range(-128.0,-64.0).unwrap();
        localo.set_occurrence_range(-64.0,0.0).unwrap();
        localo.set_occurrence_range(0.0,64.0).unwrap();
        localo.set_occurrence_range(64.0,129.0).unwrap();
        localo.add_to_counts(-99.0).unwrap();
        localo.add_to_counts(12.0).unwrap();
        localo.add_to_counts(53.0).unwrap();
        localo.add_to_counts(64.0).unwrap();
        localo.add_to_counts(3.0).unwrap();
        localo.add_to_counts(2.0).unwrap();
        localo.add_to_counts(22.0).unwrap();
        localo.add_to_counts(-22.0).unwrap();
        let result = localo.generate_count_collection();
        assert_eq!(result[1].0, -64.0);
        assert_eq!(result[1].1, 0.0);
        assert_eq!(result[1].2, 1);
        assert_eq!(result[3].0, 64.0);
        assert_eq!(result[3].1, 129.0);
        assert_eq!(result[3].2, 1);
    }

    #[test]
    fn test_validation_that_the_range_is_complete() {
        let mut localo = HistogramOfX::new(-128.0,128.0).unwrap();
        localo.set_occurrence_range(-128.0,-64.0).unwrap();
        localo.set_occurrence_range(-64.0,0.0).unwrap();
        localo.set_occurrence_range(0.0,64.0).unwrap();
        localo.set_occurrence_range(64.0,129.0).unwrap();
        localo.validate_ranges_complete().unwrap();
        localo.set_occurrence_range(244.0,256.0).unwrap();
        let resulto: Result<(),ValidationError> = localo.validate_ranges_complete();
        match resulto {
            Ok(()) =>panic!("Ok should not occur, so it fails this test."), 
            Err(_err) => true,
        };
    }
       
    // SumsOfPowers

    #[test]
    fn test_has_just_one_native_constructor() {
        let mut localo = SumsOfPowers::new(false);
        assert_eq!(localo.n,0);
        localo.add_to_sums(1234.56789);
        assert_eq!(localo.n,1);
    }

    #[test]
    fn test_generation_of_pearson_s_first_skewness_coefficient_with_class_method() {
        // Need data here for better knowledge.  For now just make sure a number comes out.
        let a = SumsOfPowers::calculate_pearsons_first_skewness_coefficient(25.0,3.0,1.57).unwrap();
        assert_eq!(14.012738853503183, a);
    }
       
    #[test]
    fn test_generation_of_pearson_s_second_skewness_coefficient_with_class_method() {
        // Need data here for better knowledge.  For now just make sure a number comes out.
        let a = SumsOfPowers::calculate_pearsons_second_skewness_coefficient(25.0,3.0,1.57).unwrap();
        assert_eq!(14.012738853503183, a);
    }
       
    #[test]
    fn test_generate_second_moment_subject_xs_sum() {
        let mut localo = SumsOfPowers::new(false);
        assert_eq!(localo.n,0);
        let resulto = localo._calculate_second_moment_subject_xs();
        match resulto {
            Ok(_floatthing) => panic!("Ok should not occur, so it fails this test:  {_floatthing}"), 
            Err(_err)       => true,
        };
        localo.add_to_sums(3.0);
        localo.add_to_sums(4.0);
        localo.add_to_sums(5.0);
        assert_eq!(localo.n,3);
        let a = localo._calculate_second_moment_subject_xs().unwrap();
        assert_eq!(44.666666666666664, a);
    }

    #[test]
    fn test_generate_third_moment_subject_xs_sum() {
        let mut localo = SumsOfPowers::new(false);
        assert_eq!(localo.n,0);
        let a = localo._calculate_third_moment_subject_xs().unwrap();
        assert_eq!(0.0,a);
        localo.add_to_sums(3.0);
        localo.add_to_sums(4.0);
        localo.add_to_sums(5.0);
        assert_eq!(localo.n,3);
        let a = localo._calculate_third_moment_subject_xs().unwrap();
        assert_eq!(128.0,a);
    }

    #[test]
    fn test_generate_fourth_moment_subject_xs_sum() {
        let mut localo = SumsOfPowers::new(false);
        assert_eq!(localo.n,0);
        let a = localo._calculate_fourth_moment_subject_xs().unwrap();
        assert_eq!(0.0,a);
        localo.add_to_sums(3.0);
        localo.add_to_sums(4.0);
        localo.add_to_sums(5.0);
        let a = localo._calculate_fourth_moment_subject_xs().unwrap();
        assert_eq!(-510.0,a);
    }

    #[test]
    fn test_adding_to_the_sums() {
        let mut localo = SumsOfPowers::new(false);
        assert_eq!(localo.n,0);
        localo.add_to_sums(3.0);
        assert_eq!(1,localo.n);
        localo.add_to_sums(3.0);
        localo.add_to_sums(4.0);
        localo.add_to_sums(5.0);
        assert_eq!(4,localo.n);
    }

    #[test]
    fn test_generating_kurtosis() {
        let a           = [3.0,3.0,4.0,5.0];
        let llen        = a.len();
        let mut localo  = SumsOfPowers::new(false);
        assert_eq!(localo.n,0);
        let lsum        = a.iter().sum();
        localo.set_to_diffs_from_mean_state(lsum,llen).unwrap();
        assert_eq!(localo.n,llen);
        assert_eq!(localo.n,4);
        localo.add_to_sums(a[0]);
        assert_eq!(localo.n,4);
        localo.add_to_sums(a[1]);
        localo.add_to_sums(a[2]);
        localo.add_to_sums(a[3]);
        assert_eq!(localo.n,4);
        let result = localo.request_kurtosis().unwrap();
        assert_eq!(4.48879632289572,result);
    }

    #[test]
    fn test_generating_skewness() {
        let mut localo  = SumsOfPowers::new(false);
        assert_eq!(localo.n,0);
        localo.add_to_sums(3.0);
        assert_eq!( 1, localo.n );
        localo.add_to_sums(3.0);
        localo.add_to_sums(4.0);
        localo.add_to_sums(5.0);
        localo.add_to_sums(6.0);
        assert_eq!(localo.n,5);
        let result = localo.request_skewness(3).unwrap();
        assert_eq!(56.25011459381775,result);
    }

    #[test]
    fn test_generating_standard_deviation() {
        let mut localo  = SumsOfPowers::new(false);
        assert_eq!(localo.n,0);
        localo.add_to_sums(3.0);
        assert_eq!( 1, localo.n );
        localo.add_to_sums(3.0);
        localo.add_to_sums(4.0);
        localo.add_to_sums(4.0);
        let result = localo.generate_standard_deviation().unwrap();
        assert_eq!( 0.5773502691896257, result)
    }

    #[test]
    fn test_generating_variance() {
        let mut localo  = SumsOfPowers::new(false);
        localo.set_to_diffs_from_mean_state(15.0,4).unwrap();
        localo.add_to_sums(3.0);
        localo.add_to_sums(3.0);
        localo.add_to_sums(4.0);
        localo.add_to_sums(5.0);
        // This way of doing it is badly confusing.  Better that they either be:
        // 1.  Independent methods running only off argument inputs.
        // 2.  Validate for state, so they cannot run if calcualtions were done under wrong state.
        let result = localo.calculate_variance_using_subject_as_diffs().unwrap();
        assert_eq!( 19.666666666666668, result );
        let mut localo  = SumsOfPowers::new(false);
        localo.add_to_sums(3.0);
        localo.add_to_sums(3.0);
        localo.add_to_sums(4.0);
        localo.add_to_sums(5.0);
        let result = localo.calculate_variance_using_subject_as_sum_xs().unwrap();
        assert_eq!( 0.9166666666666666, result );
    }

    // VectorOfX, VectorOfContinuous, VectorOfDiscrete

/*345678901234567890123456789012345678901234567890123456789012345678901234567890
    Tests for trait VectorOfX implemented for VectorOfContinuous.
     */

    #[test]
    fn test_bad_data_action_identifiers() {
        /* I found the popular advice around enums to be confusing and perhaps even
        gratuituosly obscure.  Enums make a type, and you gotta make identifiers for
        them to use values for them.  As such, I made constants.  Due to the less
        than concrete state of documentation for things like this in Rust, I'm still
        not sure my usage is considered regular, nor if it is optimal.
         */
        let bdaa = [BLANKFIELD,DEFAULTFILL,EXCLUDEROW,FAIL,SKIPDATAITEM,ZEROFLOAT,ZEROINTEGER];
        assert_eq!(bdaa.len(),7);
        for &lbda in bdaa.iter() {
            match lbda {
                BLANKFIELD      => assert!(true),
                DEFAULTFILL     => assert!(true),
                EXCLUDEROW      => assert!(true),
                FAIL            => assert!(true),
                SKIPDATAITEM    => assert!(true),
                ZEROFLOAT       => assert!(true),
                ZEROINTEGER     => assert!(true),
                _               => panic!("Test failed."),
            };
        }
    }

    #[test]
    fn test_basic_construction_and_get_count_method() {
        let mut localo  = init_vector_of_continuous();
        localo.push_x_str("1234.56",FAIL).unwrap();
        let n           = localo.get_count();
        assert_eq!(n,1);
        assert_eq!("statistics1v::VectorOfContinuous",localo.get_implementation_name());
    }

    #[test]
    fn test_various_array_construction_methods() {
        let a: Vec<&str>    = vec!["3", "2", "1"];
        let mut localo      = init_vector_of_continuous();
        localo.load_from_str_vector(a,FAIL).unwrap();
        assert_eq!(localo.get_count(),3);
        let a: Vec<&str>    = vec!["1.5","99","5876.1234","String"];
        let mut localo      = init_vector_of_continuous();
        localo.load_from_str_vector(a,SKIPDATAITEM).unwrap();
        assert_eq!(localo.get_count(),3);
        let a: Vec<f64>     = vec![1.5,99.0,5876.1234,3.0,2.0,1.0];
        let mut localo      = init_vector_of_continuous();
        localo.load_from_f64(a);
        assert_eq!(localo.get_count(),6);
        let a: Vec<f64>     = vec![1.5,99.0,5876.1234,3.0,2.0,1.0,1.0,2.0,3.0];
        let mut localo      = init_vector_of_continuous();
        localo.load_from_f64(a);
        assert_eq!(localo.get_count(),9);
        let a: Vec<i32>     = vec![1,99,5876,3,2,1,1,2,3];
        let mut localo      = init_vector_of_continuous();
        localo.load_from_i32(a);
        assert_eq!(localo.get_count(),9);
    }

    #[test]
    fn test_sorted_vector_function_and_get_x_method() {
        let a: Vec<&str>    = vec!["3", "2", "1"];
        let mut localo      = init_vector_of_continuous();
        localo.load_from_str_vector(a,FAIL).unwrap();
        let n               = localo.get_count();
        assert_eq!(n,3);
        localo._assure_sorted_vector_of_x(false);
        assert_eq!(3,localo.sorted_vector_of_x.len());
        let x0              = localo.get_x(0).unwrap();
        assert_eq!(3.0,x0);
        assert_eq!(2.0,localo.get_x(1).unwrap());
        assert_eq!(1.0,localo.get_x(2).unwrap());
        let a: Vec<&str>    = vec!["1.5","99","5876.1234","String"];
        let mut localo      = init_vector_of_continuous();
        localo.load_from_str_vector(a,SKIPDATAITEM).unwrap();
        assert_eq!(localo.get_count(),3);
    }


    #[test]
    fn test_push_x_methods() {
        let mut localo = init_vector_of_continuous();
        localo.push_x_str("11234.51234",FAIL).unwrap();
        assert_eq!(localo.get_count(),1);
        localo.push_x_string("98765.43210".to_string(),FAIL).unwrap();
        assert_eq!(localo.get_count(),2);
        localo.push_x(10101010.202020202);
        assert_eq!(localo.get_count(),3);
    }

    #[test]
    fn test_request_result_aa_output_methods() {
        let a: Vec<&str>    = vec!["3", "2", "1"];
        let mut localo = init_vector_of_continuous();
        localo.load_from_str_vector(a,FAIL).unwrap();
        localo.push_x_str("11234.51234",FAIL).unwrap();
        localo.push_x_string("98765.43210".to_string(),FAIL).unwrap();
        localo.push_x(10101010.202020202);
        let resultbm        = match localo.request_summary_collection().unwrap() {
            None            => panic!("Test failed."),
            Some(buffer)    => buffer,
        };
        for (key, value) in resultbm.iter() {
            println!("trace key, value:  {}, {}",key, value);
        }
        assert_eq!(resultbm.len(),17);
        let csvstring       = match localo.request_result_aa_csv().unwrap() {
            None            => panic!("Test failed."),
            Some(buffer)    => buffer,
        };
        assert_eq!(csvstring.len(),299);
        let csvstring       = match localo.request_result_csv_line(false).unwrap() {
            None            => panic!("Test failed."),
            Some(buffer)    => buffer,
        };
        assert_eq!(csvstring.len(),146);
        let jsonstring      = match localo.request_result_json().unwrap() {
            None            => panic!("Test failed."),
            Some(buffer)    => buffer,
        };
        assert_eq!(jsonstring.len(),480);
    }


/*345678901234567890123456789012345678901234567890123456789012345678901234567890
    # Tests for remainder of VectorOfContinuous implementation.
     */

    #[test]
    fn test_has_internal_focused_method_to_construct_a_new_sums_of_powers_object_for_moment_statistics() {
        let a: Vec<&str>    = vec!["3", "2", "1"];
        let mut localo = init_vector_of_continuous();
        match localo.load_from_str_vector(a,FAIL) {
            Ok(())          => (),
            Err(_err)       => panic!("Test failed."),
        }
        assert_eq!(3,localo.get_count());
        localo._add_up_xs_to_sums_of_powers(false,false).unwrap();
        localo._add_up_xs_to_sums_of_powers(false,true).unwrap();
        localo._add_up_xs_to_sums_of_powers(true,false).unwrap();
        localo._add_up_xs_to_sums_of_powers(true,true).unwrap();
        assert_eq!(3,localo.get_count());
        assert_eq!(3,localo.sums_of_powers_object.n);
    }

    #[test]
    fn test_has_internal_focused_method_to_decide_startno_value_for_histogram() {
        let a: Vec<&str>    = vec!["1", "2", "3"];
        let mut localo = init_vector_of_continuous();
        match localo.load_from_str_vector(a,FAIL) {
            Ok(())          => (),
            Err(_err)       => panic!("Test failed."),
        }
        assert_eq!(3,localo.get_count());
        let startno = localo._decide_histogram_start_number(true,1.0);
        assert_eq!(1.0,startno);
        let startno = localo._decide_histogram_start_number(false,0.0);
        assert_eq!(1.0,startno);
    }

    #[test]
    fn test_calculates_arithmetic_mean_in_two_places() {
        let a: Vec<&str>    = vec!["1", "2", "3"];
        let mut localo = init_vector_of_continuous();
        match localo.load_from_str_vector(a,FAIL) {
            Ok(())          => (),
            Err(_err)       => panic!("Test failed."),
        }
        let vocoam          = localo.calculate_arithmetic_mean().unwrap();
        localo._add_up_xs_to_sums_of_powers(false,false).unwrap();
        assert_eq!(vocoam,localo.sums_of_powers_object.arithmetic_mean);
        localo._add_up_xs_to_sums_of_powers(false,true).unwrap();
        assert_eq!(vocoam,localo.sums_of_powers_object.arithmetic_mean);
        localo._add_up_xs_to_sums_of_powers(true,false).unwrap();
        let pam1            = localo.sums_of_powers_object.arithmetic_mean;
        localo._add_up_xs_to_sums_of_powers(true,true).unwrap();
        let pam2            = localo.sums_of_powers_object.arithmetic_mean;
        assert_eq!(pam1,pam2);
    }

    #[test]
    fn test_calculates_geometric_mean() {
        let a               = vec!["1","2","3","4","5"];
        let mut localo      = init_vector_of_continuous();
        localo.load_from_str_vector(a,FAIL).unwrap();
        let gmean           = localo.calculate_geometric_mean().unwrap();
        assert_eq!(2.6052,gmean);
        let a               = vec![2.0,2.0,2.0,2.0];
        let mut localo      = init_vector_of_continuous();
        localo.load_from_f64(a);
        let amean           = localo.calculate_arithmetic_mean().unwrap();
        let gmean           = localo.calculate_geometric_mean().unwrap();
        assert_eq!(amean,gmean);
        let a               = vec![1,2,3,4,5,6,7,8,9];
        let mut localo      = init_vector_of_continuous();
        localo.load_from_i32(a);
        let amean           = localo.calculate_arithmetic_mean().unwrap();
        let gmean           = localo.calculate_geometric_mean().unwrap();
        assert!(amean > gmean);
    }

    #[test]
    fn test_calculates_harmonic_mean() {
        let a = vec![1,2,3,4,5];
        let mut localo = init_vector_of_continuous();
        localo.load_from_i32(a);
        let hmean           = match localo.calculate_harmonic_mean().unwrap() {
            None            => panic!("Test failed."),
            Some(buffer)    => buffer,
        };
        assert_eq!( 2.1898, hmean );
        let a               = vec![2,2,2,2];
        let mut localo      = init_vector_of_continuous();
        localo.load_from_i32(a);
        let amean           = localo.calculate_arithmetic_mean().unwrap();
        let gmean           = localo.calculate_geometric_mean().unwrap();
        let hmean           = match localo.calculate_harmonic_mean().unwrap() {
            None            => panic!("Test failed."),
            Some(buffer)    => buffer,
        };
        assert_eq!(amean,gmean);
        assert_eq!(amean,hmean);
        let a               = vec![1,2,3,4,5,6,7,8,9];
        let mut localo      = init_vector_of_continuous();
        localo.load_from_i32(a);
        let amean           = localo.calculate_arithmetic_mean().unwrap();
        let gmean           = localo.calculate_geometric_mean().unwrap();
        let hmean           = match localo.calculate_harmonic_mean().unwrap() {
            None            => panic!("Test failed."),
            Some(buffer)    => buffer,
        };
        assert!(amean > gmean);
        assert!(gmean > hmean);
    }

    #[test]
    fn test_has_a_calculate_quartile_method_which_returns_the_value_for_a_designated_quartile() {
        let mut a       = vec![0,1,2,3,4,5,6,7,8,9,8,9,9,9,9,9,8,7,8,7,8,7,6,5,4,3,2,1,0];
        a.sort();
        let mut localo = init_vector_of_continuous();
        localo.load_from_i32(a);
        let qv      = match localo.calculate_quartile(1).unwrap() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };
        assert_eq!( qv, 3.0 );

        let a       = vec![1,2,3,4,5];
        let mut localo = init_vector_of_continuous();
        localo.load_from_i32(a);
        let qv      = match localo.calculate_quartile(0).unwrap() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };
        assert_eq!( qv, 1.0 );
        let qv      = match localo.calculate_quartile(1).unwrap() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };
        assert_eq!( qv, 2.0 );
        let qv      = match localo.calculate_quartile(2).unwrap() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };
        assert_eq!( qv, 3.0 );
        let qv      = match localo.calculate_quartile(3).unwrap() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };
        assert_eq!( qv, 4.0 );
        let qv      = match localo.calculate_quartile(4).unwrap() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };
        assert_eq!( qv, 5.0 );

        let a       = vec![0,1,2,3,4,5,6,7,8,9,8,9,9,9,9,9,8,7,8,7,8,7,6,5,4,3,2,1,0];
        let mut localo = init_vector_of_continuous();
        localo.load_from_i32(a);
        let qv      = match localo.calculate_quartile(0).unwrap() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };
        assert_eq!( qv, 0.0 );
        let qv      = match localo.calculate_quartile(1).unwrap() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };
        assert_eq!( qv, 3.0 );
        let qv      = match localo.calculate_quartile(2).unwrap() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };
        assert_eq!( qv, 7.0 );
        let qv      = match localo.calculate_quartile(3).unwrap() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };
        assert_eq!( qv, 8.0 );
        let qv      = match localo.calculate_quartile(4).unwrap() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };
        assert_eq!( qv, 9.0 );
    }

    #[test]
    fn test_generates_a_average_absolute_deviation_for_arithmetic_geometric_harmonic_means_median_min_max_mode() {
        let mut localo = init_vector_of_continuous();
        let a           = vec![1.0,2.0,3.0,4.0,5.0,6.0,7.0,8.9];
        localo.load_from_f64(a);
        let amaad       = match localo.generate_average_absolute_deviation(VectorOfContinuous::ARITHMETICMEANID).unwrap() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };
        assert_eq!( 2.1125, amaad );
        let gmaad       = match localo.generate_average_absolute_deviation(VectorOfContinuous::GEOMETRICMEANID).unwrap() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };
        assert_eq!( 2.1588, gmaad );
        let hmaad       = match localo.generate_average_absolute_deviation(VectorOfContinuous::HARMONICMEANID).unwrap() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };
        assert_eq!( 2.3839, hmaad );
        let medianaad   = match localo.generate_average_absolute_deviation(VectorOfContinuous::MEDIANID).unwrap() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };
        assert_eq!( 2.1125, medianaad );
        let minaad      = match localo.generate_average_absolute_deviation(VectorOfContinuous::MINID).unwrap() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };
        assert_eq!( 3.6125, minaad );
        let maxaad      = match localo.generate_average_absolute_deviation(VectorOfContinuous::MAXID).unwrap() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };
        assert_eq!( 4.2875, maxaad );
        /*
        let modeaad     = match localo.generate_average_absolute_deviation(VectorOfContinuous::MODEID).unwrap() {
            None    => None,
            Some(b) => panic!("Test failed."),
        };
        assert_eq!( 4.2875, modeaad ); This fails because of new implementation of mode, which causes better result, and
        needs to be implemented in other language versions. NOTE:  TBD.
         */
        let a           = vec![0,1,2,3,4,5,6,7,8,9,8,9,9,9,9,9,8,7,8,7,8,7,6,5,4,3,2,1,0];
        let mut localo = init_vector_of_continuous();
        localo.load_from_i32(a);
        let aad         = match localo.generate_average_absolute_deviation(VectorOfContinuous::ARITHMETICMEANID).unwrap() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };
        assert_eq!( 2.6112, aad );
        let aad         = match localo.generate_average_absolute_deviation(VectorOfContinuous::MEDIANID).unwrap() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };
        assert_eq!( 2.5172, aad );
    }

    #[test]
    fn test_generates_a_coefficient_of_variation() {
        let mut localo = init_vector_of_continuous();
        let a           = vec![1.0,2.0,3.0,4.0,5.0,6.0,7.0,8.9];
        localo.load_from_f64(a);
        let amean       = localo.calculate_arithmetic_mean().unwrap();
        let stddev      = match localo.request_standard_deviation().unwrap() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };
        let herecov     = round_to_f64_precision(stddev / amean, localo.out_precision);
        let cov         = match localo.generate_coefficient_of_variation().unwrap() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };
        assert_eq!( cov, herecov );
    }

    #[test]
    fn test_has_two_methods_to_generate_a_matrix_of_histogram_data() {
        let mut localo = init_vector_of_continuous();
        let a           = vec![1,2,3,4,5,6,7,8,9];
        localo.load_from_i32(a);
        let hdaa        = match localo.generate_histogram_aa_by_number_of_segments(3,true,1.0).unwrap() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };
        assert_eq!( 3, hdaa.len());
        let hdaa        = match localo.generate_histogram_aa_by_number_of_segments(3,true,0.0).unwrap() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };
        assert_eq!( 3, hdaa.len());
        let hdaa        = match localo.generate_histogram_aa_by_number_of_segments(3,true,-1.0).unwrap() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };
        assert_eq!( 3, hdaa.len());
        let hdaa        = match localo.generate_histogram_aa_by_number_of_segments(4,true,1.0).unwrap() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };
        assert_eq!( 4, hdaa.len());
        let hdaa        = match localo.generate_histogram_aa_by_number_of_segments(5,true,0.0).unwrap() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };
        assert_eq!( 5, hdaa.len());
        let hdaa        = match localo.generate_histogram_aa_by_segment_size(2.0,true,1.0).unwrap() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };
        let diff0       = hdaa[0].1 - hdaa[0].0;
        assert_eq!( diff0, 2.0 );
        let diff1       = hdaa[1].1 - hdaa[1].0;
        assert_eq!( diff1, 2.0 );
        let hdaa        = match localo.generate_histogram_aa_by_segment_size(3.0,true,0.0).unwrap() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };
        let diff2       = hdaa[2].1 - hdaa[2].0;
        assert_eq!( diff2, 3.0 );
    }

    #[test]
    fn test_generates_a_mean_absolute_difference() {
        let mut localo = init_vector_of_continuous();
        let a       = vec![1.0,2.0,3.0,4.0,5.0,6.0,7.0,8.9];
        localo.load_from_f64(a);
        let mad     = match localo.generate_mean_absolute_difference().unwrap() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };
        assert_eq!( 3.225, mad );
    }

    #[test]
    fn test_can_get_the_minimum_median_maximum_and_mode() {
        let mut localo = init_vector_of_continuous();
        let a           = vec![1,2,3,4,5,6,7,8,9];
        localo.load_from_i32(a);
        assert_eq!( localo.get_count(), 9 );
        assert_eq!( 1.0, localo.get_min().unwrap() );
        assert_eq!( 5.0, localo.request_median().unwrap() );
        assert_eq!( 9.0, localo.get_max().unwrap() );
        let modefailure = match localo.generate_mode() {
            None    => true,
            Some(_b) => panic!("Test failed."),
        }; // New method designates no mode when there are none with more than 1 occurrence.
        assert!(modefailure);
        let mut localo = init_vector_of_continuous();
        let a           = vec![1,2,3,4,5,6,7,8,9,8,7,8];
        localo.load_from_i32(a);
        let mma         = localo.request_range().unwrap();
        assert_eq!( localo.get_count(), 12 );
        assert_eq!( 1.0, mma[0] );
        assert_eq!( 6.5, localo.request_median().unwrap() );
        assert_eq!( 9.0, mma[1] );
        let mode        = match localo.generate_mode() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };// New method designates no mode when there are none with more than 1 occurrence.
        assert_eq!( 8.0, mode );
    }

    #[test]
    fn test_has_a_method_to_test_if_the_vector_of_x_has_an_even_n() {
        let mut localo = init_vector_of_continuous();
        let a       = vec![1.0,2.0,3.0,4.0,5.0,6.0,7.0,8.9];
        localo.load_from_f64(a);
        assert!(localo.is_n_even());
        let mut localo = init_vector_of_continuous();
        let a       = vec![1.0,2.0,3.0,4.0,5.0,6.0,7.0,8.9,11.0];
        localo.load_from_f64(a);
        assert!( ! localo.is_n_even() );
    }

    #[test]
    fn test_has_an_method_to_return_get_because_it_is_direct_call_to_language_method_the_sum() {
        let a       = vec![1,2,2,3,3,3];
        let mut localo = init_vector_of_continuous();
        localo.load_from_i32(a);
        assert_eq!( localo.get_count(), 6 );
        assert_eq!( 14.0, localo.calculate_sum() );
    }

    #[test]
    fn test_can_request_calculation_of_kurtosis() {
        let mut localo = init_vector_of_continuous();
        let a                                   = vec![1,2,3,4,5,6,7,8,9];
        localo.load_from_i32(a);
        let ek                                  = match localo.request_excess_kurtosis(2).unwrap() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };
        assert_eq!( -1.23, ek );
        let ek                                  = match localo.request_excess_kurtosis(3).unwrap() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };
        assert_eq!( -1.2, ek );
        let k                                   = match localo.request_kurtosis().unwrap() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };
        assert_eq!( 1.8476, k );

        localo.use_diff_from_mean_calculations  = false;
        match localo.request_kurtosis() {
            Err(_err)   => (),
            Ok(_b)       => panic!("Test failed."),
        };
        //assert_eq!( 1.8476, k ); This combination not implemented for this language yet.
    }

    #[test]
    fn test_can_request_a_complete_collection_of_all_5_quartiles_in_an_array() {
        let mut localo = init_vector_of_continuous();
        let a           = vec![1,2,3,4,5];
        localo.load_from_i32(a);
        let qv          = match localo.request_quartile_collection().unwrap() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };
        assert_eq!( 1.0, qv[0] );
        assert_eq!( 2.0, qv[1] );
        assert_eq!( 3.0, qv[2] );
        assert_eq!( 4.0, qv[3] );
        assert_eq!( 5.0, qv[4] );
        let a           = vec![0.0,1.0,2.0,3.0,4.0,5.0,6.0,7.0,8.0,9.0,8.0,9.0,9.0,9.0,9.0,9.0,8.0,7.0,8.0,7.0,8.0,7.0,6.0,5.0,4.0,3.0,2.0,1.0,0.0,1.0,2.0,2.0,3.0,3.0,3.0,99.336,5.9,259.0,1133.7,1234.0];
        let mut localo = init_vector_of_continuous();
        localo.load_from_f64(a);
        let qv          = match localo.request_quartile_collection().unwrap() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };
        assert_eq!( 0.0, qv[0] );
        assert_eq!( 3.0, qv[1] );
        assert_eq!( 6.0, qv[2] );
        assert_eq!( 8.25, qv[3] );
        assert_eq!( 1234.0, qv[4] );
    }

    #[test]
    fn test_has_some_formatted_result_methods() {
        let mut localo = init_vector_of_continuous();
        let a               = vec![1,2,3,4,5,6,7,8,9];
        localo.load_from_i32(a);
        let aacsvstr        = match localo.request_result_aa_csv().unwrap() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };
        assert_eq!(aacsvstr.len(),228);
        let aacsvlinestr    = match localo.request_result_csv_line(true).unwrap() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };
        assert_eq!(aacsvlinestr.len(),230);
        let aajsonstr       = match localo.request_result_json().unwrap() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };
        assert_eq!(aajsonstr.len(),409);
    }

    #[test]
    fn test_can_request_a_calculation_of_skewness() {
        let mut localo = init_vector_of_continuous();
        let a           = vec![1,2,3,4,5,6,7,8,9];
        localo.load_from_i32(a);
        let sk          = match localo.request_skewness(1).unwrap() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };
        assert_eq!( 0.0, sk );
        let sk          = match localo.request_skewness(2).unwrap() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };
        assert_eq!( 0.0, sk );
        let sk          = match localo.request_skewness(3).unwrap() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };
        assert_eq!( 0.0, sk );
        let a           = vec![1,2,2,3,3,3,4,4,4,4,4,4];
        let mut localo = init_vector_of_continuous();
        localo.load_from_i32(a);
        let sk          = match localo.request_skewness(1).unwrap() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };
        assert_eq!( -0.7545, sk );
        let sk          = match localo.request_skewness(2).unwrap() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };
        assert_eq!( -0.8597, sk );
        let sk          = match localo.request_skewness(3).unwrap() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };
        assert_eq!( -0.9878, sk );
    }

    #[test]
    fn test_has_four_standard_deviation_calculations_corresponding_to_the_four_variance_combinations() {
        let mut localo = init_vector_of_continuous();
        let a                                   = vec![1,2,3];
        localo.load_from_i32(a);
        let sdsd                                = match localo.request_standard_deviation().unwrap() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };
        localo.use_diff_from_mean_calculations  = false;
        let sdsx                                = match localo.request_standard_deviation().unwrap() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };
        assert_eq!( sdsd, sdsx );
        localo.population                       = true;
        localo.use_diff_from_mean_calculations  = true;
        let sdsd                                = match localo.request_standard_deviation().unwrap() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };
        localo.use_diff_from_mean_calculations  = false;
        let sdsx                                = match localo.request_standard_deviation().unwrap() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };
        assert_eq!( sdsd, sdsx );
    }

    #[test]
    fn test_has_two_variance_generation_methods() {
        let mut localo = init_vector_of_continuous();
        let a           = vec![1.0,2.0,2.0,3.0,3.0,3.0,99.336,5.9,601.0,1133.7,1234.0];
        localo.load_from_f64(a);
        let v           = match localo.request_variance_sum_of_differences_from_mean(false).unwrap() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };
        assert_eq!( 231232.125543275, v );
        let v           = match localo.request_variance_sum_of_xs_squared_method(true).unwrap() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };
        assert_eq!( 210211.02322115703, v );
        let v           = match localo.request_variance_sum_of_differences_from_mean(true).unwrap() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };
        assert_eq!( 210211.0232211591, v );
        let v           = match localo.request_variance_sum_of_xs_squared_method(true).unwrap() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };
        assert_eq!( 210211.02322115703, v );
    }

    #[test]
    fn test_input_routine_pushx_validates_arguments() {
        let mut localo = init_vector_of_continuous();
        localo.push_x(123.456);
        localo.push_x_str("9999999999999999999999999999",FAIL).unwrap();
    }

    #[test]
    fn test_fails_differently_according_to_special_arguments_to_pushx() {
        let mut localo = init_vector_of_continuous();
        assert_eq!( 0, localo.get_count() );
    }

//345678901234567890123456789012345678901234567890123456789012345678901234567890
    // Tests for VectorOfDiscrete

    #[test]
    fn test_constructs_with_no_argument() {
        let mut localo = init_vector_of_discrete();
        localo.push_x_str("5.333",FAIL);
        localo.push_x_str("Any old str",FAIL);
        localo.push_x_string("Any old string".to_string(),FAIL);
        assert_eq!( 3, localo.get_count());
        assert_eq!("statistics1v::VectorOfDiscrete",localo.get_implementation_name());
    }

    #[test]
    fn test_constructs_with_a_str_slice_vec() {
        let a       = vec!["1.5","99","5876.1234","some old string"];
        let mut localo  = init_vector_of_discrete();
        match localo.load_from_str_vector(a,FAIL) {
            Ok(())   => (),
            Err(_e) => panic!("Failed test."),
        };
        assert_eq!( 4, localo.get_count());
    }

    #[test]
    fn test_has_a_binomial_probability_calculation() {
        let a       = vec!["1","2","3","4","5","6","7","8","9","8"];
        let mut localo  = init_vector_of_discrete();
        match localo.load_from_str_vector(a,FAIL) {
            Ok(())   => (),
            Err(_e) => panic!("Failed test."),
        };
        assert_eq!( 10, localo.get_count() );
        match localo.calculate_binomial_probability("8".to_string(),3,1) {
            Ok(b)       => {
                match b {
                    None        => panic!("Test failed."),
                    Some(b2)    => assert_eq!( 0.3840000000000001, b2 ),
                }
            },
            Err(_err)   => panic!("Test failed:  {:?}",_err),
        }
    }

    #[test]
    fn test_has_a_method_to_get_the_mode() {
        let a           = vec!["1.5","99","5876.1234","some old string","99"];
        let mut localo  = init_vector_of_discrete();
        match localo.load_from_str_vector(a,FAIL) {
            Ok(())  => (),
            Err(_e) => panic!("Failed test."),
        };
        assert_eq!( 5, localo.get_count() );
        let lmode       = match localo.request_mode() {
            None    => panic!("Test failed."),
            Some(b) => b,
        };
        assert_eq!( "99", lmode );
    }

    // VectorTable

//345678901234567890123456789012345678901234567890123456789012345678901234567890
    // Tests for VectorTable

    // Primary Example:  ./testdata/doexampledata.csv
    // year_month,month_of_release,passenger_type,direction,sex,age,estimate,standard_error,status
    // 2001-01,2020-09,Long-term migrant,Arrivals,Female,0-4 years,344,0,Final

    #[test]
    fn test_constructs_with_just_a_class_column_argument() {
           // 2001-01,2020-09,Long-term migrant,Arrivals,Male,0-4 years,341,0,Final
        let vcsa    = vec![VectorClassId::VODID,VectorClassId::VODID,VectorClassId::VODID,VectorClassId::VODID,VectorClassId::VODID,VectorClassId::VODID,VectorClassId::VOCID,VectorClassId::VOCID,VectorClassId::VODID];
        let localo  = VectorTable::new(vcsa);
        assert_eq!(9,localo.get_column_count());
        assert_eq!(0,localo.get_row_count());
    }
    
    #[test]
    fn test_allows_adding_a_data_row_s_of_vector_elements() {
           // 2001-01,2020-09,Long-term migrant,Arrivals,Male,0-4 years,341,0,Final
        let vcsa = vec![VectorClassId::VODID,VectorClassId::VODID,VectorClassId::VODID,VectorClassId::VODID,VectorClassId::VODID,VectorClassId::VODID,VectorClassId::VOCID,VectorClassId::VOCID,VectorClassId::VODID];
        let mut localo = VectorTable::new(vcsa);
        assert_eq!(0,localo.get_row_count());
        let a = vec!["Nil0".to_string(),"Nil1".to_string(),"Nil2".to_string(),"Nil3".to_string(),"Nil4".to_string(),"Nil5".to_string(),123456.to_string(),77.to_string(),"Nil8".to_string()];
        localo.push_table_row(a,FAIL).unwrap();
        assert_eq!(9,localo.get_column_count());
        assert_eq!(1,localo.get_row_count());
        let lvi6oeo = localo.get_vector_of_continuous_object(6).unwrap();
        assert_eq!("statistics1v::VectorOfContinuous",lvi6oeo.get_implementation_name());
        let lvi7oeo = localo.get_vector_of_continuous_object(7).unwrap();
        assert_eq!("statistics1v::VectorOfContinuous",lvi7oeo.get_implementation_name());
        let lvi8oeo = localo.get_vector_of_discrete_object(8).unwrap();
        assert_eq!("statistics1v::VectorOfDiscrete",lvi8oeo.get_implementation_name());
    }

}

//345678901234567890123456789012345678901234567890123456789012345678901234567890
// End of SamesLib.neophyte.rs
