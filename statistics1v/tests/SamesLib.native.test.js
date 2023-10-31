/*345678901234567890123456789012345678901234567890123456789012345678901234567890
  test_WPMS2023.js automation tests of WPMS2023.js
    Note:  if, due to my being in a hurry, cited examples do not yet have
    reference URLs, you can probably find them by searching with a randomly
    selected string, however:  TBD.
 */

//345678901234567890123456789012345678901234567890123456789012345678901234567890
// Constants and Includes

const WPMS2023 = require('./WPMS2023.js');

//345678901234567890123456789012345678901234567890123456789012345678901234567890
// Tests

describe('isANumStr', () => {

    test('Discerns if value has a String that could be parsed as a number.', () => {
        expect(WPMS2023.isANumStr('1234')).toBe(true);
        expect(WPMS2023.isANumStr('1234.56789')).toBe(true);
        expect(WPMS2023.isANumStr('.1234')).toBe(true);
        expect(WPMS2023.isANumStr('1234.0')).toBe(true);
        expect(WPMS2023.isANumStr('12 34')).toBe(false);
        expect(WPMS2023.isANumStr('12x34')).toBe(false);
        expect(WPMS2023.isANumStr('A')).toBe(false);
        expect(WPMS2023.isANumStr('%')).toBe(false);
        expect(WPMS2023.isANumStr('####')).toBe(false);
    });

    test('Rejects non-strings.', () => {
        expect(WPMS2023.isANumStr(1234)).toBe(false);
        expect(WPMS2023.isANumStr(15.993)).toBe(false);
        expect(WPMS2023.isANumStr(0.1234)).toBe(false);
    });

});

describe('isNumber', () => {

    test('Discerns if value has a String that could be parsed as a number.', () => {
        expect(WPMS2023.isNumber(1)).toBe(true);
        expect(WPMS2023.isNumber('x')).toBe(false);
        expect(WPMS2023.isNumber('1')).toBe(false);
    });

});

describe('isNumericvector', () => {

    test('It discerns whether all elements of a vector are good numbers for data.', () => {
        expect(WPMS2023.isNumericVector([1,2,3,4,5])).toBe(true);
        expect(WPMS2023.isNumericVector(['1',2,'33.33',"4"])).toBe(false);
        expect(WPMS2023.isNumericVector(['1',2])).toBe(false);
        expect(WPMS2023.isNumericVector([2,'33.33'])).toBe(false);
        expect(WPMS2023.isNumericVector(["4",5,6])).toBe(false);
        expect(WPMS2023.isNumericVector([2,33.33,4,0x5,12341234123412341234])).toBe(true);
        expect(WPMS2023.isNumericVector(['x',2,3,4,5])).toBe(false);
        expect(WPMS2023.isNumericVector([' 1 1 ',2,3,4,5])).toBe(false);
    });

});

describe('isOnlyWhitespace', () => {

    test('Should be true for any string with no non-whitespace characters.', () => {
        expect(WPMS2023.isOnlyWhitespace(' ')).toBe(true);
        expect(WPMS2023.isOnlyWhitespace('              ')).toBe(true);
    });

    test('Should throw if the argument is not a string.', () => {
        expect(WPMS2023.isOnlyWhitespace('  ')).toBe(true);
        expect(function() {
            WPMS2023.isOnlyWhitespace(999);
        }).toThrow();
    });

});

describe('isUsableNumber', () => {

    test('Accepts any number or string that can be parsed as a number.', () => {
        expect(WPMS2023.isUsableNumber(1234)).toBe(true);
        expect(WPMS2023.isUsableNumber(15.993)).toBe(true);
        expect(WPMS2023.isUsableNumber(0.1234)).toBe(true);
        expect(WPMS2023.isUsableNumber('1234')).toBe(true);
        expect(WPMS2023.isUsableNumber('1234.56789')).toBe(true);
        expect(WPMS2023.isUsableNumber('.1234')).toBe(true);
        expect(WPMS2023.isUsableNumber('1234.0')).toBe(true);
    });

    test('Rejects non-numeric stuff.', () => {
        expect(WPMS2023.isUsableNumber('%')).toBe(false);
        expect(WPMS2023.isUsableNumber('12 34')).toBe(false);
        expect(WPMS2023.isUsableNumber('12x4')).toBe(false);
        expect(WPMS2023.isUsableNumber('A')).toBe(false);
        expect(WPMS2023.isUsableNumber(/blek/)).toBe(false);
        expect(WPMS2023.isUsableNumber('{}')).toBe(false);
        expect(WPMS2023.isUsableNumber({})).toBe(false);
    });

});

describe('isUsableNumberVector', () => {

    test('It discerns whether all elements of a vector are good numbers for data.', () => {
        expect(WPMS2023.isUsableNumberVector([1,2,3,4,5])).toBe(true);
        expect(WPMS2023.isUsableNumberVector(['1',2,'33.33',"4"])).toBe(true);
        expect(WPMS2023.isUsableNumberVector(['1',2])).toBe(true);
        expect(WPMS2023.isUsableNumberVector(["4"])).toBe(true);
        expect(WPMS2023.isUsableNumberVector(["4",5,6])).toBe(true);
        expect(WPMS2023.isUsableNumberVector([2,33.33,4,0x5,12341234123412341234])).toBe(true);
        expect(WPMS2023.isUsableNumberVector(['x',2,3,4,5])).toBe(false);
        expect(WPMS2023.isUsableNumberVector([' 1 1 ',2,3,4,5])).toBe(false);
    });

});


describe('VectorOfX', () => {

    test('Constructor works to make an object.', () => {
        let localo = new WPMS2023.VectorOfX;
        expect(typeof localo).toBe('object');
    });

});

describe('VectorOfContinuous', () => {

    test('Constructor works to make an object.', () => {
        let localo = new WPMS2023.VectorOfX;
        expect(typeof localo).toBe('object');
    });

    test('Constructs with no argument.', () => {
        expect(function() {
            new WPMS2023.VectorOfContinuous;
        }).not.toThrow();
        let localo = new WPMS2023.VectorOfContinuous;
        expect( localo.constructor ).toStrictEqual(WPMS2023.VectorOfContinuous);
        expect(function() {
            localo.pushX(5.333);
        }).not.toThrow();
    });

    test('Constructs with a Javascript Array.', () => {
        expect(function() {
            new WPMS2023.VectorOfContinuous([1.5,99,5876.1234]);
        }).not.toThrow();
        let localo = new WPMS2023.VectorOfContinuous([99.336,5.9,0x259,88441133.7,1234]);
        expect( localo.constructor ).toStrictEqual(WPMS2023.VectorOfContinuous);
    });

    test('Provides a number of useful calculations.', () => {
        let a0  = [0,1,2,3,4,5,6,7,8,9];
        let a1  = [0.0,1.1,2.2,3.3,4.4,5.5,6.6,7.7,8.8,9.9];
        let a2  = [99.336,5.9,0x259,88441133.7,1234,1.5,99,5876.1234];
        let l0o = new WPMS2023.VectorOfContinuous(a0);
        let mu = l0o.genMean();
        expect( mu ).toBe(4.5000);
        let msd = l0o.genMeanStdDev();
        expect( msd ).toBe(3.0277);
        // Median is also broken:  TBD
        //let med = l0o.genMedian();
        //expect( med ).toBe('5');
        //let mod = l0o.genMode();
        // expect( mod ).toBe(0); // Mode is just wrong, so I need to revisit the calculation.  Probably needs an ending mean.
        // This mode calculation is wrong across al languages.  I need to address it in second draft.
        //let qua = l0o.genQuartiles();
        // Skipping quartiles until later too.
        //expect( qua.constructor ).toStrictEqual(Array);
        //expect( qua.length ).toBe(5);
        let l1o = new WPMS2023.VectorOfContinuous(a1);
        let l2o = new WPMS2023.VectorOfContinuous(a2);
    });

});

describe('VectorOfDiscrete', () => {

    test('Constructor works to make an object.', () => {
        let localo = new WPMS2023.VectorOfDiscrete;
        expect(typeof localo).toBe('object');
    });

});

describe('VectorTable', () => {

    test('Constructs with just a class/column argument.', () => {
        //      2001-01,2020-09,Long-term migrant,Arrivals,Male,0-4 years,341,0,Final
        let vcsa = [null,null,null,null,null,null,WPMS2023.VectorOfContinuous,WPMS2023.VectorOfContinuous,null];
        expect(function() {
            new WPMS2023.VectorTable(vcsa);
        }).not.toThrow();
        let localo = new WPMS2023.VectorTable(vcsa);
        expect( localo.constructor ).toStrictEqual(WPMS2023.VectorTable);
    });

    test('Allows adding a data row of vector elements.', () => {
        //      2001-01,2020-09,Long-term migrant,Arrivals,Male,0-4 years,341,0,Final
        let vcsa = [null,null,null,null,null,null,WPMS2023.VectorOfContinuous,WPMS2023.VectorOfContinuous,null];
        let localo = new WPMS2023.VectorTable(vcsa);
        let a = ['Null0','Null1','Null2','Null3','Null4','Null5',123456,77,'Null8'];
        localo.pushTableRow(a);
        let lvi6o = localo.getVectorObject(6);
        expect( lvi6o.constructor ).toStrictEqual(WPMS2023.VectorOfContinuous);
        let lvi7o = localo.getVectorObject(7);
        expect( lvi7o.constructor ).toStrictEqual(WPMS2023.VectorOfContinuous);
    });

    test('Allows a user to load column values from a CSV file (and make all the calculations on vectors filled).', () => {
        //     2001-01,2020-09,Long-term migrant,Arrivals,Male,0-4 years,341,0,Final
        let fspec   = 'testdata/doexampledata.csv';  // See first 32 lines of this file near bottom.
        let vcsa = [null,null,null,null,null,null,WPMS2023.VectorOfContinuous,WPMS2023.VectorOfContinuous,null];
        let localo  = WPMS2023.VectorTable.newFromCSV(fspec,vcsa);
        let lvi6o = localo.getVectorObject(6);
        let n = lvi6o.genCount();
        expect(n).toBe(44310);
        let mu = lvi6o.genMean();
        expect(mu).toBe(437.2062);
        let msd = lvi6o.genMeanStdDev();
        expect(msd).toBe(1195.4808);
        let lvi7o = localo.getVectorObject(7);
        mu = lvi7o.genMean();
        msd = lvi7o.genMeanStdDev();
        expect(mu).toBe(0.5492);
        expect(msd).toBe(4.0465);
    });


});

//Begin First 32 lines of doexampledata.csv:
/*
year_month,month_of_release,passenger_type,direction,sex,age,estimate,standard_error,status
2001-01,2020-09,Long-term migrant,Arrivals,Female,0-4 years,344,0,Final
2001-01,2020-09,Long-term migrant,Arrivals,Male,0-4 years,341,0,Final
2001-01,2020-09,Long-term migrant,Arrivals,Female,10-14 years,459,0,Final
2001-01,2020-09,Long-term migrant,Arrivals,Male,10-14 years,510,0,Final
2001-01,2020-09,Long-term migrant,Arrivals,Female,15-19 years,899,0,Final
2001-01,2020-09,Long-term migrant,Arrivals,Male,15-19 years,904,0,Final
2001-01,2020-09,Long-term migrant,Arrivals,Female,20-24 years,566,0,Final
2001-01,2020-09,Long-term migrant,Arrivals,Male,20-24 years,566,0,Final
2001-01,2020-09,Long-term migrant,Arrivals,Female,25-29 years,659,0,Final
2001-01,2020-09,Long-term migrant,Arrivals,Male,25-29 years,604,0,Final
2001-01,2020-09,Long-term migrant,Arrivals,Female,30-34 years,514,0,Final
2001-01,2020-09,Long-term migrant,Arrivals,Male,30-34 years,502,0,Final
2001-01,2020-09,Long-term migrant,Arrivals,Female,35-39 years,460,0,Final
2001-01,2020-09,Long-term migrant,Arrivals,Male,35-39 years,407,0,Final
2001-01,2020-09,Long-term migrant,Arrivals,Female,40-44 years,328,0,Final
2001-01,2020-09,Long-term migrant,Arrivals,Male,40-44 years,348,0,Final
2001-01,2020-09,Long-term migrant,Arrivals,Female,45-49 years,206,0,Final
2001-01,2020-09,Long-term migrant,Arrivals,Male,45-49 years,221,0,Final
2001-01,2020-09,Long-term migrant,Arrivals,Female,5-9 years,407,0,Final
2001-01,2020-09,Long-term migrant,Arrivals,Male,5-9 years,404,0,Final
2001-01,2020-09,Long-term migrant,Arrivals,Female,50-54 years,142,0,Final
2001-01,2020-09,Long-term migrant,Arrivals,Male,50-54 years,171,0,Final
2001-01,2020-09,Long-term migrant,Arrivals,Female,55-59 years,93,0,Final
2001-01,2020-09,Long-term migrant,Arrivals,Male,55-59 years,104,0,Final
2001-01,2020-09,Long-term migrant,Arrivals,Female,60-64 years,74,0,Final
2001-01,2020-09,Long-term migrant,Arrivals,Male,60-64 years,69,0,Final
2001-01,2020-09,Long-term migrant,Arrivals,Female,65-69 years,61,0,Final
2001-01,2020-09,Long-term migrant,Arrivals,Male,65-69 years,42,0,Final
2001-01,2020-09,Long-term migrant,Arrivals,Female,70-74 years,32,0,Final
2001-01,2020-09,Long-term migrant,Arrivals,Male,70-74 years,37,0,Final
2001-01,2020-09,Long-term migrant,Arrivals,Female,75-79 years,21,0,Final
 */
//End of First 32 lines of doexampledata.csv:
//345678901234567890123456789012345678901234567890123456789012345678901234567890
// End of WPMS2023.test.js
