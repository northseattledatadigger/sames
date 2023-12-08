//345678901234567890123456789012345678901234567890123456789012345678901234567890
// SamesLib.neophyte.rs

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

//use core::str;
//use csv;
//use phf;
//use phf_macros::phf_map;
use regex::Regex;
use serde::{Serialize, Deserialize};
//use serde::Serialize;
use std::collections::*;
//use std::{error::Error, fmt};
//use std::process::{ExitCode, Termination};
//use thiserror::Error;
//use std::collections::HashMap;

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
    #[error("Method may only be used with Differences from Mean Data.")]
    MethodOnlyForDiffFromMeanData(),
    #[error("Method may only be used with Sums of Xs Data.")]
    MethodOnlyForSumOfXsData(),
    #[error("No range found for value: '{0}'")]
    NoRangeFoundForValue(f64),
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
    #[error("Value {0} may not be negative.")]
    ValueMayNotBeNegative(f64),
    #[error("Value {0} may not be zero.")]
    ValueMayNotBeZero(f64),
    #[error("Low value {0} NOT below high value {1}")]
    ValueOrderWrong(f64,f64),
    #[error("Value Range Conflict [{0},{1}] overlaps [{2},{3}]")]
    ValueRangeConflict(f64,f64,f64,f64),
    #[error("Zero Result not considered valid.")]
    ZeroResultInvalid(),
}

//345678901234567890123456789012345678901234567890123456789012345678901234567890
// Global Procedures

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

pub fn generate_mode_from_frequency_aa<'a>(faa_a: &'a BTreeMap<&'a str, u32>) -> Option<&'a str> {
    let mut k: &'a str;
    let mut m: u32 = 0;
    let mut candidates: HashSet<&'a str> = HashSet::new();
    for (key, &value) in faa_a.iter() {
        if value == m {
            candidates.insert(key);
        }
        if value > m {
            candidates.clear();
            candidates.insert(key);
            k = key;
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

pub fn insert_op_data_to_str_aa(operation_option_output: Option<f64>,aa_buffer: BTreeMap<&str,&str>,data_id: &str) {
    let str_data    = match operation_option_output {
        None            => "None",
        Some(buffer)    => format!("{}",buffer).as_str(),
    }; 
    aa_buffer.insert(data_id,str_data);
}

pub fn is_a_num_str(str_a: &str) -> bool {
    let sstr = str_a.trim();
    let re = Regex::new(r"^-?\d*\.?\d+$").unwrap();
    if re.is_match(sstr) {
        return true;
    }
    return false;
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

pub fn is_whitespace_only(str_a: &str) -> bool {
    let sstr = str_a.trim();
    if sstr.len() > 0 {
        return false;
    }
    return true;
}

pub fn parse_float_left_of_decimal(subject_float: f64,precision: i32) -> f64 {
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

pub fn push_i128_from_f64(precision: i32,subject_float: f64, sorting_vector: &Vec<i128>) {
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
            //frequency_aa: BTreeMap<i64, RangeOccurrence>::new(),
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

enum BadDataAction {
    BlankField,
    DefaultFill,
    ExcludeRow,
    Fail,
    SkipRow,
    ZeroField,
}

pub trait VectorOfX {

    fn _assure_sorted_vector_of_x(&self,force_sort: bool);
    fn _n_zero(&self) -> bool;
    fn get_count(&self) -> usize;
    fn get_x(&self,index_a: usize,sorted_vector: bool) -> Result<f64,ValidationError>;
    fn new() -> Self;
    fn new_after_invalidated_dropped(vector_of_x: Vec<&str>) -> Self;
    fn push_x_string(&mut self, x_string: &str) -> Result<(), ValidationError>;

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

impl Default for VectorOfContinuous {
    fn default() -> Self {
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
}

impl VectorOfX for VectorOfContinuous {

    fn _assure_sorted_vector_of_x(&self,force_sort: bool) {
        if self.sorted_vector_of_x.len() == self.vector_of_x.len() {
            if ! force_sort {
                return ();
            }
        }
        self.sorted_vector_of_x.clear();
        for lx in self.vector_of_x.iter() {
            push_i128_from_f64(self.in_precision,*lx,&self.sorted_vector_of_x);
        }
        self.sorted_vector_of_x.sort();
    }

    fn _n_zero(&self) -> bool {
        if self.get_count() == 0 {
            return true;
        }
        return false;
    }

    fn get_count(&self) -> usize {
        let n = self.vector_of_x.len();
        return n;
    }

    fn get_x(&self,index_a: usize,sorted_vector: bool) -> Result<f64,ValidationError> {
        let n = self.get_count();
        if n <= index_a {
            let m = "Index argument {index_a} is greater than or equal to n {n}".to_string();
            return Err(ValidationError::InvalidArgument(m));
        }
        if sorted_vector {
            self._assure_sorted_vector_of_x(false); // in case update occurred from pushX.
            let buffer = from_i128_to_f64(self.in_precision,self.sorted_vector_of_x[index_a]);
            return Ok(buffer);
        } else {
            return Ok(self.vector_of_x[index_a]);
        }
    }

    fn new() -> Self {
        let mut buffer: VectorOfContinuous = Default::default();
        return buffer;
    }

    fn new_after_invalidated_dropped(vector_of_x: Vec<&str>) -> Self {
        let mut buffer: VectorOfContinuous = Default::default();
        for lx in vector_of_x.iter() {
            buffer.push_x_string(lx);
        }
        return buffer;
    }

    fn push_x_string(&mut self, x_string: &str) -> Result<(), ValidationError> {
        /*  NOTE:  TBD figure out return value from parse expect trim etc and
            deal with that.
         */
        let result                  = x_string.trim().parse();
        let x_float_unrounded = match result {
            Ok(unrounded)   => unrounded,
            Err(_err)       => return Err(ValidationError::ParseErrorOnWouldBeNumberString(x_string.to_string())),
        };
        let x_float                 = round_to_f64_precision(x_float_unrounded, self.in_precision);
        self.vector_of_x.push(x_float);
        return Ok(());
    }

}

impl VectorOfContinuous {

    const ARITHMETICMEANID: &str    = "ArithmeticMean";
    const ARMEANAADID: &str         = "AMeanAAD"; // Average Absolute Deviation
    // Note; I have Max and Min available for AAD, but presume these will not be used formally.
    const COVPOPULATIONID: &str     = "PopulationCoefficientOfVariation";
    const COVSAMPLEID: &str         = "SampleCoefficientOfVariation";
    const COVID: &str               = "CoefficientOfVariation";
    const GEOMETRICMEANID: &str     = "GeometricMean";
    const GMEANAADID: &str          = "GMeanAAD"; // Geometric Mean Average Absolute Deviation
    const HARMONICMEANID: &str      = "HarmonicMean";
    const HMEANAADID: &str          = "HMeanAAD"; // Harmonic Mean Average Absolute Deviation
    const ISEVENID: &str            = "IsEven";
    const KURTOSISID: &str          = "Kurtosis";
    const MADID: &str               = "MAD"; // Mean Absolute Difference  NOTE that this will not be addressed in acceptance tests due to a paucity of presence in common apps.
    const MAXID: &str               = "Max";
    const MEDIANAADID: &str         = "MedianAAD";// Median Absolute Deviation
    const MEDIANID: &str            = "Median";
    const MINID: &str               = "Min";
    const MODEAADID: &str           = "ModeAAD"; // Mode Absolute Deviation
    const MODEID: &str              = "Mode";
    const NID: &str                 = "N";
    const SKEWNESSID: &str          = "Skewness";
    const STDDEVID: &str            = "StandardDeviation";
    const STDDEVDIFFSPOPID: &str    = "StddevDiffsPop";
    const STDDEVDIFFSSAMPLEID: &str = "StddevDiffsSample";
    const STDDEVSUMXSPOPID: &str    = "StddevSumxsPop";
    const STDDEVSUMXSSAMPLEID: &str = "StddevSumxsSample";
    const SUMID: &str               = "Sum";

    fn _add_up_xs_to_sums_of_powers(&mut self,population_calculation: bool,sum_of_diffs: bool) -> Result<(), ValidationError> {
        self.sums_of_powers_object  = SumsOfPowers::new(population_calculation);
        if self.use_diff_from_mean_calculations {
            let n                   = self.get_count();
            let sum                 = self.calculate_sum();
            self.sums_of_powers_object.set_to_diffs_from_mean_state(sum,n)?;
        }
        if self.use_diff_from_mean_calculations {
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

    fn _decide_histogram_start_number(&self,use_start_number: bool,start_number: f64) -> f64 {
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
        if self._n_zero() {
            return None;
        }
        let nf          = self.get_count() as f64;
        let sumxs       = self.calculate_sum();
        let unrounded   = sumxs / nf;
        let mean        = round_to_f64_precision(unrounded, self.out_precision);
        return Some(mean);
    }

    pub fn calculate_geometric_mean(&self) -> Option<f64> {
        if self._n_zero() {
            return None;
        }
        let nf          = self.get_count() as f64;
        let exponent    = 1.0 / nf;
        let productxs   = self.vector_of_x.into_iter().reduce(|a, b| a * b)?;
        let unrounded   = productxs.powf(exponent);
        let rounded     = round_to_f64_precision(unrounded, self.out_precision);
        return Some(rounded);
    }

    pub fn calculate_harmonic_mean(&self) -> Result<Option<f64>, ValidationError> {
        if self._n_zero() {
            return Ok(None);
        }
        let nf                  = self.get_count() as f64;
        let sumreciprocals: f64 = 0.0;
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

    pub fn calculate_quartile(&self,q_no: u8) -> Result<Option<f64>, ValidationError> {
        if self._n_zero() {
            return Ok(None);
        }
        if q_no < 0 {
            return Err(ValidationError::ValueMayNotBeNegative(q_no as f64));
        }
        if 5 < q_no {
            let m = "Value q_no '{q_no}' may not be larger than 5.".to_string();
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
        if self._n_zero() {
            return 0.0;
        }
        let sumxs = self.vector_of_x.iter().sum();
        return sumxs;
    }

    pub fn generate_average_absolute_deviation(&self,central_point_type: &str) -> Result<Option<f64>, ValidationError> {
        if self._n_zero() {
            return Ok(None);
        }
        let cpf: f64;
        let option = ();
        let result = ();
        match central_point_type {
            ArithmeticMeanId    => option = self.calculate_arithmetic_mean(),
            GeometricMeanId     => option = self.calculate_geometric_mean(),
//NOTE:  Stopped here.  Proceed on return 20231208
            HarmonicMeanId      => result = self.calculate_harmonic_mean(),
            MaxId               => option = self.get_max(),
            MedianId            => option = self.request_median(),
            MinId               => option = self.get_min(),
            ModeId              => option = self.generate_mode(),
            _ => {
                let m = "This Average Absolute Mean formula has not implemented a statistic for central point '#{central_point_type}' at this time.".to_string();
                return Err(ValidationError::ArgumentError(m));
            },
            match result {
                Ok
        };
        let nf                  = self.get_count() as f64;
        let sumofabsolutediffs  = 0;
        for lx in self.vector_of_x.iter() {
            let previous        = sumofabsolutediffs;
            sumofabsolutediffs  += ( lx - cpf ).abs();
            if previous > sumofabsolutediffs {
                return Err(ValidationError::UnexpectedReducedValue(sumofabsolutediffs,previous));
            }
        }
        let unrounded           = sumofabsolutediffs / nf;
        let rounded             = round_to_f64_precision(unrounded, self.out_precision);
        return Ok(Some(rounded));
    }

    pub fn generate_coefficient_of_variation(&self) -> Result<Option<f64>, ValidationError> {
        if self._n_zero() {
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

    pub fn generate_histogram_aa_by_number_of_segments(&self,desired_segment_count: u8,start_number: f64) -> Result<Option<Vec<(f64,f64,usize)>>, ValidationError> {
        if self._n_zero() {
            return Ok(None);
        }
        let lmax            = self.get_max().unwrap(); // Presuming from n > 0 this will always be a Some.
        let startno         = self._decide_histogram_start_number(start_number);
        let histo           = HistogramOfX::new_from_desired_segment_count(startno,lmax,desired_segment_count)?;
        histo.validate_ranges_complete()?;
        for lx in self.vector_of_x.iter() {
            histo.add_to_counts(lx)
        }
        let resultvectors   = histo.generate_count_collection();
        return Ok(Some(resultvectors));
    }

    pub fn generate_histogram_aa_by_segment_size(&self,desired_segment_size: f64,start_number: f64) -> Result<Option<Vec<(f64,f64,usize)>>, ValidationError> {
        if self._n_zero() {
            return Ok(None);
        }
        let lmax            = self.get_max().unwrap(); // Presuming from n > 0 this will always be a Some.
        let startno         = self._decide_histogram_start_number(start_number);
        let histo           = HistogramOfX::new_from_desired_segment_size(startno,lmax,desired_segment_size)?;
        histo.validate_ranges_complete()?;
        for lx in self.vector_of_x.iter() {
            histo.add_to_counts(lx)
        }
        let resultvectors   = histo.generate_count_collection();
        return Ok(Some(resultvectors));
    }

    fn generate_mean_absolute_difference(&self) -> Result<Option<f64>, ValidationError> {
        // https://en.wikipedia.org/wiki/Mean_absolute_difference
        if self._n_zero() {
            return Ok(None);
        }
        let nf                      = self.get_count() as f64;
        let sumofabsolutediffs: f64 = 0.0;
        for lxi in self.vector_of_x.iter() {
            for lxj in self.vector_of_x.iter() {
                sumofabsolutediffs  += ( lxi - lxj ).abs
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

    fn generate_mode(&self) -> Option<&str> {
        /* NOTE:  Because matching floats is not a practical enterprise,
            or at least given I have other infrastructure to do it that
            I choose to use, I'll instead crop to out precision, and
            format to strings, then pick by string equal value, and
            convert back go f64 to return.  This may seem cockamamie,
            and is slower, but the point is not efficiency in any of these
            drafts not specifically labeled as such anyway.
         */
        if self._n_zero() {
            return None;
        }
        let lsaa: BTreeMap<&str,u32>    = BTreeMap::new();
        for lx in self.vector_of_x.iter() {
            let btkey = lx.to_string();
            if lsaa.contains_key(btkey) {
                lsaa[btkey]             += 1;
            } else {
                lsaa[btkey]             = 1;
            }
        }
        let option                      = generate_mode_from_frequency_aa(lsaa)?;
        let modestr                     = match option {
            None            => return Ok(None),
            Some(buffer)    => buffer,
        };
        let modefloat                   = modestr.parse::<f64>().unwrap();
        return Ok(Some(modefloat));
    }

    pub fn get_max(&self) -> Option<f64> {
        if self._n_zero() {
            return None;
        }
        let max_opval = self.vector_of_x.iter().max();
        return Same(max_opval);
    }

    pub fn get_min(&self) -> Option<f64> {
        if self._n_zero() {
            return None;
        }
        let min_opval = self.vector_of_x.iter().min();
        return Some(min_opval);
    }

    pub fn is_even_n(&self) -> bool {
        let n = self.get_count();
        if n % 2 == 0 {
            return true
        }
        return false;
    }

    pub fn new_from_string_number_vector(vector_of_x: Vec<&str>) -> Result<Self, ValidationError> {
        let mut buffer: VectorOfContinuous = Default::default();
        for lx in vector_of_x.iter() {
            buffer.push_x_string(lx)?;
        }
        return buffer;
    }

    pub fn push_x(&mut self, x_float_unrounded: f64) {
        let x_float = round_to_f64_precision(x_float_unrounded, self.in_precision);
        self.vector_of_x.push(x_float);
    }

    pub fn request_excess_kurtosis(&self,formula_id: u8) -> Result<Option<f64>, ValidationError> {
        if self._n_zero() {
            return Ok(None);
        }
        if ! self.use_diff_from_mean_calculations {
            return Err(ValidationError::ProcedureNotProgrammedForState("May NOT be used with Sum of Xs Data."));
        }
        self._add_up_xs_to_sums_of_powers(self.population,self.use_diff_from_mean_calculations)?;
        let unrounded: f64 = 
            match formula_id {
            2   => self.sums_of_powers_object.calculateExcessKurtosis_2_JR_R()?,
            3   => self.sums_of_powers_object.generateExcessKurtosis_3_365datascience()?,
            _   => {
                let m = "There is no excess kurtosis formula {formulaId} implemented at this time.";
                return Err(ValidationError::InvalidArgument(m));
            }
        };
        let rounded             = round_to_f64_precision(unrounded, self.out_precision);
        return Ok(Some(rounded));
    }

    pub fn request_kurtosis(&self) -> Result<Option<f64>, ValidationError> {
        if self._n_zero() {
            return Ok(None);
        }
        self._add_up_xs_to_sums_of_powers(self.population,self.use_diff_from_mean_calculations)?;
        let unrounded   = self.sums_of_powers_object.requestKurtosis()?;
        let rounded     = round_to_f64_precision(unrounded, self.out_precision);
        return Ok(Some(rounded));
    }

    pub fn request_median(&self) -> Option<f64> {
        if self._n_zero() {
            return None)
        }
        let median = match self.calculate_quartile(2) {
            Ok(buffer) => buffer,
            Err(_err) => panic!("Cannot happen, practically.");
        }
        return Some(median);
    }

    pub fn request_quartile_collection(&self) -> Result<Option<[f64;5]>, ValidationError> {
        if self._n_zero() {
            return Ok(None);
        }
        let qos0    = calculate_quartile(0)?;
        let qos1    = calculate_quartile(1)?;
        let qos2    = calculate_quartile(2)?;
        let qos3    = calculate_quartile(3)?;
        let qos4    = calculate_quartile(4)?;
        let ra      = [qos0,qos1,qos2,qos3,qos4];
        return Ok(Some(ra))
    }

    pub fn request_range(&self) -> Option<[f64;2]> {
        if self._n_zero() {
            return None;
        }
        let lmax = self.get_max();
        let lmin = self.get_min();
        return Some([lmin,lmax]);
    }

    pub fn request_result_aa_csv(&self) -> Result<Option<&str>, ValidationError> {
        if self._n_zero() {
            return Ok(None);
        }
        let option          = self.request_summary_collection()?;
        let scaa            = match option {
            None            => return Ok(None),
            Some(aabuffer)  => aabuffer,
        };
        let b       = format!(  collection_csv_line_fmt_str!(),
                        Self::ARITHMETICMEANID,         scaa[Self::ARITHMETICMEANID],
                        Self::ARMEANAADID,              scaa[Self::ARMEANAADID],
                        Self::COEFFICIENTOFVARIATIONID, scaa[Self::COEFFICIENTOFVARIATIONID],
                        Self::GEOMETRICMEANID,          scaa[Self::GEOMETRICMEANID],
                        Self::HARMONICMEANID,           scaa[Self::HARMONICMEANID],
                        Self::ISEVENID,                 scaa[Self::ISEVENID],
                        Self::KURTOSISID,               scaa[Self::KURTOSISID],
                        Self::MAXID,                    scaa[Self::MAXID],
                        Self::MEDIANID,                 scaa[Self::MEDIANID],
                        Self::MEDIANAADID,              scaa[Self::MEDIANAADID],
                        Self::MINID,                    scaa[Self::MINID],
                        Self::MODEID,                   scaa[Self::MODEID],
                        Self::NID,                      scaa[Self::NID],
                        Self::SKEWNESSID,               scaa[Self::SKEWNESSID],
                        Self::STDDEVID,                 scaa[Self::STDDEVID],
                        Self::SUMID,                    scaa[Self::SUMID]);
        return Ok(Some(b));
    }

//345678901234567890123456789012345678901234567890123456789012345678901234567890
    pub fn request_result_csv_line(&self,include_hdr: bool) -> Result<Option<&str>, ValidationError> {
        // NOTE: Mean Absolute Diffence is no longer featured here.
        if self._n_zero() {
            return Ok(None);
        }
        let option          = self.request_summary_collection()?;
        let scaa            = match option {
            None            => return Ok(None),
            Some(aabuffer)  => aabuffer,
        };
        let csvline         =
            format!(collection_csv_table_fmt_str!(),
                    scaa[Self::ARITHMETICMEANID],
                    scaa[Self::ARMEANAADID],
                    scaa[Self::COEFFICIENTOFVARIATIONID],
                    scaa[Self::GEOMETRICMEANID],
                    scaa[Self::HARMONICMEANID],
                    scaa[Self::ISEVENID],
                    scaa[Self::KURTOSISID],
                    scaa[Self::MAXID],
                    scaa[Self::MEDIANID],
                    scaa[Self::MEDIANAADID],
                    scaa[Self::MINID],
                    scaa[Self::MODEID],
                    scaa[Self::NID],
                    scaa[Self::SKEWNESSID],
                    scaa[Self::STDDEVID],
                    scaa[Self::SUMID]);
        if include_hdr {
            let csvhdr      =
                format!(collection_csv_table_fmt_str!(),
                        Self::ARITHMETICMEANID,
                        Self::ARMEANAADID,
                        Self::COEFFICIENTOFVARIATIONID,
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
        return csvline;
    }

    pub fn request_result_json(&self) -> Result<Option<&str>, ValidationError> {
        if self._n_zero() {
            return Ok(None);
        }
        let option      = self.request_summary_collection()?;
        let scaa        = match option {
            None            => return Ok(None),
            Some(aabuffer)  => aabuffer,
        };
        // let jsonstr = serde_json::to_string(&scaa)?; // Need to handle non ValidationError error.
        let jsonstring  = serde_json::to_string(&scaa)?;
        return Ok(Some(jsonstring));
    }

    pub fn request_skewness(&self,formula_id: u8) -> Result<Option<f64>, ValidationError> {
        if self._n_zero() {
            return Ok(None);
        }
        self._add_up_xs_to_sums_of_powers(self.population,self.use_diff_from_mean_calculations)?;
        let unrounded   = self.sums_of_powers_object.request_skewness(formula_id)?;
        let rounded     = round_to_f64_precision(unrounded, self.out_precision);
        return Ok(rounded);
    }

    pub fn request_standard_deviation(&self) -> Result<Option<f64>, ValidationError> {
        if self._n_zero() {
            return Ok(None);
        }
        self._add_up_xs_to_sums_of_powers(self.population,self.use_diff_from_mean_calculations)?;
        let unrounded   = self.sums_of_powers_object.generateStandardDeviation()?;
        if unrounded == 0.0 {
            return Err(ValidationError::ValueMayNotBeZero(unrounded));
        }
        let stddev      = round_to_f64_precision(unrounded, self.out_precision);
        return Ok(Some(stddev));
    }

    pub fn request_summary_collection(&self) -> Result<Option<BTreeMap<&str,&str>>, ValidationError> {
        // NOTE:  Some of these are ONLY for sample.  For now, this is best used ONLY for Samples,
        // NOT populations numbers.
        // NOTE:  BTreeMap usage was adopted to yield ordered output.  Other options may be reviewed
        // later.
        if self._n_zero() {
            return Ok(None);
        }
        let btmb: BTreeMap<&str,&str>   = BTreeMap::new();
        self._add_up_xs_to_sums_of_powers(self.population,self.use_diff_from_mean_calculations)?;
        insert_op_data_to_str_aa(self.calculate_arithmetic_mean()?,                                 Self::ARITHMETICMEANID, btmb);
        insert_op_data_to_str_aa(self.generate_average_absolute_deviation(Self::ARITHMETICMEANID)?, Self::ARMEANAADID,      btmb);
        insert_op_data_to_str_aa(self.generateCoefficientOfVariation()?,                            Self::COVSAMPLEID,      btmb);
        insert_op_data_to_str_aa(self.calculateGeometricMean()?,                                    Self::GEOMETRICMEANID,  btmb);
        insert_op_data_to_str_aa(self.calculateHarmonicMean()?,                                     Self::HARMONICMEANID,   btmb);
        insert_op_data_to_str_aa(self.request_kurtosis()?,                                          Self::KURTOSISID,       btmb);
        insert_op_data_to_str_aa(self.generate_mean_absolute_difference()?,                         Self::MADID,            btmb);
        insert_op_data_to_str_aa(self.request_median()?,                                            Self::MEDIANID,         btmb);
        insert_op_data_to_str_aa(self.generateAverage_absolute_deviation(Self::MEDIANID)?,          Self::MEDIANAADID,      btmb);
        insert_op_data_to_str_aa(self.get_max(),                                                    Self::MAXID,            btmb);
        insert_op_data_to_str_aa(self.get_min(),                                                    Self::MINID,            btmb);
        btmb.insert(Self::MODEID,self.generate_mode_string());
        insert_op_data_to_str_aa(self.get_count(),                                                  Self::NID,              btmb);
        insert_op_data_to_str_aa(self.request_skewness()?,                                          Self::SKEWNESSID,       btmb);
        insert_op_data_to_str_aa(self.request_standard_deviation()?,                                Self::STDDEVID,         btmb);
        insert_op_data_to_str_aa(self.calculate_sum(),                                              Self::SUMID,            btmb);
        return Ok(btmb);
    }

    pub fn request_variance_sum_of_differences_from_mean(&self,population_calculation: bool) -> Result<Option<f64>, ValidationError> {
        if self._n_zero() {
            return Ok(None);
        }
        self._add_up_xs_to_sums_of_powers(self.population,true)?;
        let v = self.sums_of_powers_object.calculate_variance_using_subject_as_diffs()?;
        // Note rounding is not done here, as it would be double rounded with stddev.
        return Ok(Some(v));
    }

    pub fn request_variance_sum_of_xs_squared_method(&self,population_calculation: bool) -> Result<Option<f64>, ValidationError> {
        if self._n_zero() {
            return Ok(None);
        }
        self._add_up_xs_to_sums_of_powers(self.population,false)?;
        let v = self.sums_of_powers_object.calculate_variance_using_subject_as_sum_xs()?;
        // Note rounding is not done here, as it would be double rounded with stddev.
        return Ok(Some(v));
    }

}

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
        let d: BTreeMap<&str, u32> = BTreeMap::from([("1234", 528), ("528", 3), ("A longer string", 0), ("x", 55555)]);
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

    // VectorTable

}

//345678901234567890123456789012345678901234567890123456789012345678901234567890
// End of SamesLib.neophyte.rs
