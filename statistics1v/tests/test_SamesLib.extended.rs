// Used by copying to compile tree.
// test_SamesLib.ext}ed.rs
//345678901234567890123456789012345678901234567890123456789012345678901234567890
// Constants and Includes

use SBinLib;
use SamesTopLib;

use rand::Rng;
use std::collections::*;
use super::*;

const FirstTestFileFn       = "sidewalkstreetratioupload.csv";
const TestDataDs            = "??";
const FirstTestFileRelFs    = "{TestDataDs}/{FirstTestFileFn}";
const FirstTestFileFs       = returnIfThere(FirstTestFileRelFs);

//345678901234567890123456789012345678901234567890123456789012345678901234567890
// Tests for Global Support Routines

// getFactorial

#[test]
fn test_can_get_factorial_for_a_pretty_large_number() {
    let n   = ffactorial(170); // This appears to be the max on my Ubuntu laptop.
    //  x   = 7.257415615e+306 was the online calculation at:  https://www.calculatorsoup.com/calculators/discretemathematics/factorials.php
    x   = 7.257415615307999e+306; // Note by the "simple" test area that I independently discovered this top number for rust in development stage.
    // Also note that I use two different factorial calculations in that version of the library.
    assert_eq!( x, n );
}

// generate_modefrom_frequency_aa(faaA)

#[test]
fn test_returns_takes_a_frequency_associative_array_and_returns_a_mode_point_statistic() {
    let h: BTreeMap<String,u32> = BTreeMap::new();
    let mut rng = rand::thread_rng();
    println!("Random number: {}", n); // Output: Random number: 42 } ...
    for i in 0..128 {
        let key: String = format!("{}",rng.gen::<u32>());
        h[key.to_owned()] = rng.gen_range(0..1024);
    }
    let result = generate_mode_from_frequency_aa(h);
    assert!(h[key] >= 0);
    assert!(h[key] <= 1024);
}

// is_usable_number_vector?

#[test]
fn test_it_discerns_whether_all_elements_of_a_vector_are_good_numbers_for_data() {
    assert!(is_usable_number_vector?(vec![1.0,2.0,3.0,4.0,5.0]));
}

//345678901234567890123456789012345678901234567890123456789012345678901234567890
// Tests for HistogramOfX class

#[test]
fn test_construction_with_large_number_of_ranges() {
    localo = HistogramOfX.new(1,5)
    assert_instance_of HistogramOfX, localo
    for i in 0..2048 {
        localo.set_occurrence_range(i,i+1);
    }
    //localo.set_occurrence_range(i,i+1); May not be needed???
    for i in 0..2048 {
        let b = rng.gen_range(0..1024);
        localo.add_to_counts(b.to_owned());
    }
    result = localo.generate_count_collection();
    assert_eq!( 2049, result.size  // This is large enough for my purposes,
                                    // I think.
}

//345678901234567890123456789012345678901234567890123456789012345678901234567890
// Tests for SumsOfPowers class

#[test]
fn test_handles_large_n() {
    localo = SumsOfPowers.new
    for _ in 0..2048 {
        localo.add_to_sums(rand);
    }
    let result = localo.generate_standard_deviation();
    assert!( result > 0 );
    let result = localo.request_skewness();
    assert!( result > 0 );
}

//345678901234567890123456789012345678901234567890123456789012345678901234567890
// Tests for Base Class VectorOfX
//
// Most testing on these routines will be in the daughter classes where the
// behavior is manifest.  Note the initialize method was only defined to aid
// these tests.

#[test]
fn test_methods_do_not_fail_with_large_n() {
    let mut a: Vec<String>  = Vec::new();
    for _ in 0..2048 {
        for _ in 0..2048 {
            a.push(rand)
        }
    }
    localo = VectorOfX.new(a)
    assert_eq!( 4194304, localo.getCount
}

//345678901234567890123456789012345678901234567890123456789012345678901234567890
// Tests for VectorOfContinuous, and most base class methods inherited.

#[test]
fn test_methods_do_not_fail_with_large_n() {
    localo = VectorOfContinuous.new
    for _ in 0..2048 {
        for _ in 0..2048 {
            let xc = rand + 1.0
            localo.pushX(xc)
        }
    }
    assert_eq!( 4194304, localo.get_count();
    let x   = localo.calculate_arithmetic_mean();
    let x   = localo.calculate_geometric_mean();
    let x   = localo.calculate_harmonic_mean();
    assert!( localo.request_standard_deviation() > 0.0 )
    let qa = localo.request_quartile_collection();
    assert!(qa[0] < qa[1]);
    assert!(qa[1] < qa[2]);
    assert!(qa[2] < qa[3]);
    assert!(qa[3] < qa[4]);
}

//345678901234567890123456789012345678901234567890123456789012345678901234567890
// Tests for VectorOfDiscrete

#[test]
fn test_methods_do_not_fail_with_large_n() {
    localo = VectorOfDiscrete.new
    for _ in 0..2048 {
        for _ in 0..2048 {
            localo.pushX(rand(100))
        }
    }
    let mode = localo.request_mode();
}

//345678901234567890123456789012345678901234567890123456789012345678901234567890
// Tests for VectorTable

#[test]
fn test_methods_do_not_fail_with_large_n() {
    let vcsa    = [VectorOfContinuous,VectorOfContinuous,VectorOfDiscrete]
    let localo  = VectorTable.new(vcsa)
    let localv0 = localo.getVectorObject(0)
    let localv1 = localo.getVectorObject(1)
    let localv2 = localo.getVectorObject(2)
    for _ in 0..2048 {
        for _ in 0..2048 {
            localv0.push_x(rand)
            localv1.push_x(rand)
            localv2.push_x("{rand(32)}")
            localo.push_table_row([rand,rand,"{rand(32)}"])
        }
    }
    assert_eq!( 8388608, localv0.get_count() );
    let x   = localv0.calculate_arithmetic_mean();
    //assert!(localv0.calculate_arithmetic_mean ();
    let x   = localv0.request_skewness();
    //assert!(localv0.request_skewness();
    let x   = localv0.request_standard_deviation();
    //assert!(localv0.requestStandard_deviation.is_a? Numeric
    assert_eq!( 8388608, localv1.get_count() );
    let x   = localv1.calculate_arithmetic_mean();
    //assert!(localv1.calculateArithmetic_mean.is_a? Numeric
    assert_eq!( 8388608, localv1.get_count() );
    let x   = localv2.request_mode();
    //assert!(localv2.requestMode.is_a? String
    let result = localv2.calculate_binomial_probability("16",29,1);
    assert!(result > 0.3 // Pretty sure it will be.
    // This should always be pretty close to the same with such a large n.
    // Using p of success 0.03110527992248535, I confirmed this at:  https://stattrek.com/online-calculator/binomial 
}

#[test]
fn test_allows_a_user_to_load_column_values_from_a_csv_file_and_make_all_the_calculations_on_vectors_filled() {
    let vcsa    = [VectorOfDiscrete,VectorOfDiscrete,VectorOfContinuous,VectorOfContinuous,VectorOfContinuous]
    let localo  = VectorTable.newFromCSV(vcsa,FirstTestFileFs,VectorOfX::DefaultFillOnBadData)
    let lvi0o   = localo.getVectorObject(0)
    let n       = lvi0o.getCount
    let mode    = lvi0o.requestMode
    //STDERR.puts "trace n:  {n}"
    //STDERR.puts "trace mode:  {mode}"
    assert_eq!( 2103, n );
    assert_eq!( "420030103001", mode );
    let lvi1o   = localo.getVectorObject(1)
    let lvi2o   = localo.getVectorObject(2)
    let lvi3o   = localo.getVectorObject(3)
    let amean   = lvi3o.calculateArithmeticMean
    let ssd     = lvi3o.requestStandardDeviation
    //STDERR.puts "trace amean:  {amean}"
    //STDERR.puts "trace ssd:  {ssd}"
    assert_eq!( 17134.3322, amean );
    assert_eq!( 29010.7171, ssd );
}


//345678901234567890123456789012345678901234567890123456789012345678901234567890
// End of test_SamesLib.ext}ed.rs
