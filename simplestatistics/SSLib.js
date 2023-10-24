/*345678901234567890123456789012345678901234567890123456789012345678901234567890
WPMS2023.js - Initial prototype was  WPMS2023.rb.
 */

"use strict";

const FS = require('fs');

//345678901234567890123456789012345678901234567890123456789012345678901234567890

function isANumStr(strA) {
    if ( typeof strA !== 'string' ) return false;
    let lstr = strA.trim();
    if ( /^-?[0-9]*\.?[0-9]+$/.test(lstr) ) return true;
    return false;
}
module.exports.isANumStr            = isANumStr;

function isNumber(vA) {
    if ( typeof vA === 'number' ) return true;
    return false;
}
module.exports.isNumber             = isNumber;

function isNumericVector(vA) {
    if ( vA.every(isNumber) ) return true;
    return false;
}
module.exports.isNumericVector      = isNumericVector;

function isOnlyWhitespace(strA) {
    if ( typeof strA !== 'string' ) {
        throw new Error(`Invalid Argument:  Must Be String:  ${strA}.`);
    }
    if ( /^\s*$/.test(strA) ) return true;
    return false;
}
module.exports.isOnlyWhitespace     = isOnlyWhitespace;

function isUsableNumber(cA) {
    if ( isNumber(cA) )     return true;
    if ( isANumStr(cA) )    return true;
    return false
}
module.exports.isUsableNumber       = isUsableNumber;

function isUsableNumberVector(vA) {
    if ( vA.every(isUsableNumber) ) return true;
    return false;
}
module.exports.isUsableNumberVector = isUsableNumberVector;

class VectorOfX {

    _VectorOfX;

    assureXsPrecision(precisionSpec) {
        throw new Error("Not Yet Implemented.");
    }

    constructor(vectorX=Array()) {
        if ( Array.isArray( vectorX ) ) {
            this._VectorOfX = vectorX;
        } else {
            throw new Error("SyntaxError:  Argument Must Be Usable as a Number.");
        }
    }

    genCount() {
        let n = this._VectorOfX.length;
        return n;
    }

    pushX(xFloat) { throw new Error("Pure Virtual."); }

}
module.exports.VectorOfX            = VectorOfX;

class VectorOfContinuous extends VectorOfX {

    UseSumOfXs;

    constructor(vectorX=[]) {
        super(vectorX);
        this.UseSumOfXs = false;
    }

    genInterQuartileRange() {
        let n = this._VectorOfX.length;
                                // Subtract one here
                                // to get the offset.
        let q1os    = 1                 - 1;
        let q2os    = ( n + 1 ) / 4     - 1;
        let q3os    = ( n / 2 )         - 1;
        let q4os    = 3 * ( q2os + 1 )  - 1;
        let qendos  = n                 - 1;
        return [ q1os,  q2os,  q3os,  q4os,  qendos ];
    }

    genMax() {
        let svox = this._VectorOfX.sort();
        return svox[-1];
    }

    genMean() {
        let n = this._VectorOfX.length;
        let sumxs = this.genSum();
        let mu = Number( ( sumxs / n ).toFixed(4) );
        return mu;
    }

    genMeanStdDev() {
        let variance = null;
        if ( this.UseSumOfXs ) {
            variance = this.genVarianceXsSquaredMethod();
        } else {
            variance = this.genVarianceSumOfDifferencesFromMean();
        }
        let stddev = Number( Math.sqrt(variance).toFixed(4) );
        return stddev
    }

    genMedian() {
        // This is broken.  Do NOT debug until later.  TBD
        let n       = this._VectorOfX.length;
        let svox    = this._VectorOfX.sort;
        if ( n % 2 == 0 ) {
            let nm2 = ( n + 1 ) / 2;
            return svox[nm2];
        } else {
            let nm2a = n / 2;
            let x1 = svox[nm2a];
            let nm2b = nm2a + 1;
            let x2 = svox[nm2b];
            let x3 = ( x1 + x2 ) / 2.0;
            let v = Number( Math.sqrt(x3).toFixed(4) );
            return v
        }
    }

    genMin() {
        let svox = this._VectorOfX.sort()
        return svox[0]
    }

    genMinMax() {
        let svox = this._VectorOfX.sort()
        return svox[0], svox.slice(-1);
    }

    genMode() {
        // This is known to be broken in Ruby.  Need attention here too.  TBD
        let h = Hash.new
        for ( const lx of this._VectorOfX ) {
            if ( lx in h )  h[lx] += 1;
            else            h[lx] = 1;
        }
        let x = 0
        let max = 0
        for ( const lx in h ) {
            if ( h[lx] > max ) {
                let x = lx;
                let max = h[lx];
            }
        }
        return x;
    }

    genNIsEven() {
        let n = this._VectorOfX.length;
        if ( n % 2 == 0 ) return true;
        return false;
    }

    genOutliers(stdDev,numberOfStdDevs=1) {
        throw new Error("Not Yet Implemented.");
    }

    genQuartiles() {
        throw new Error("Not Yet Implemented.");
    }

    genRange() {
        let svox    = this._VectorOfX.sort
        return svox[0], svox.slice(-1);
    }

    genSum() {
        let sumxs = this._VectorOfX.reduce((partial_sum,a) => partial_sum + a, 0);
        /*
        let sumxs = 0
        for ( const lx of this._VectorOfX ) {
            sumxs += Number(lx);
        }
         */
        return sumxs
    }

    genVarianceSumOfDifferencesFromMean() {
        let mu                  = this.genMean();
        let n                   = this._VectorOfX.length;
        let sumofdiffsquared    = 0;
        for ( const lx of this._VectorOfX ) {
            let xlessmu = lx - mu;
            sumofdiffsquared += ( xlessmu * xlessmu )
        }
        let variance = sumofdiffsquared / ( n - 1 );
        return variance;
    }

    genVarianceXsSquaredMethod() {
        let mu = this.genMean();
        let n = this._VectorOfX.length;
        let sumxssquared = 0;
        for ( const lx of this._VectorOfX ) {
            sumxssquared += ( lx * lx );
        }
        let variance = ( sumxssquared - ( mu * mu ) ) / ( n - 1 );
        return variance;
    }

    pushX(xFloat) {
        let n = this._VectorOfX.length;
        if ( isNumber(xFloat) ) {
            this._VectorOfX.push(xFloat);
            n = this._VectorOfX.length;
        } else
            throw new Error(`SyntaxError:  Argument '${xFloat}', of type '${typeof xFloat}', must be usable as a number.`);
    }

}
module.exports.VectorOfContinuous   = VectorOfContinuous;

class VectorOfDiscrete extends VectorOfX {
    // TBD for use with columns having discrete values.

    constructor(vectorX=[]) {
        super();
    }

}
module.exports.VectorOfDiscrete     = VectorOfDiscrete;

class VectorTable {

    static isAllowedDataVectorClass(vectorClass) {
        if ( vectorClass === VectorOfContinuous ) return true
        return false
    }

    static newFromCSV(fSpec,vcSpec,skipFirstLine=true) {
        let localo = new VectorTable(vcSpec);
        let i = 0;

        const data = FS.readFileSync(fSpec, 'utf8');
        for ( const ll of data.split('\n') ) {
            if ( ( i == 0 ) && ( skipFirstLine ) ) {
                i += 1;
                continue
            }
            if ( isOnlyWhitespace(ll) ) {
                i += 1;
                if ( localo.IgnoreBadLines ) continue;
                throw new Error(`Blank or whitespace only line:  |${ll}|`);
            }
            let sll = ll.trim();
            let columns = sll.split(/\s*,\s*/);
            if ( localo.RowColumns != columns.length ) {
                i += 1;
                if ( this.IgnoreBadLines ) continue;
                throw new Error(`${i+1}th row had ${columns.length} columns, rather than ${localo.RowColumns}.`);
            }
            i += 1;
            if ( localo.pushTableRow(columns) ) continue;
            throw new Error(`Invalid Data Line [$i]: |${sll}|`);
        }
        return localo;
    }

    constructor(vectorOfClasses) {
        if ( vectorOfClasses === 'array' ) {
            throw new Error("SyntaxError:  Argument Must 'array'.");
        }

        this.IgnoreBadLines     = true;
        this.RowColumns         = vectorOfClasses.length;
        this.TableOfVectors     = [];
        this.VectorOfClasses    = vectorOfClasses;
        let buffer = null;
        for ( const lci of this.VectorOfClasses ) {
            if ( lci ) {
                if ( ! VectorTable.isAllowedDataVectorClass(lci) ) {
                    throw new Error("SyntaxError:  Class must be in set VectorTable accepts.");
                }
                buffer = new lci;
            } else {
                buffer = null;
            }
            this.TableOfVectors.push( buffer );
        }
    }

    getVectorObject(indexNo) {
        if ( VectorTable.isAllowedDataVectorClass( this.TableOfVectors[indexNo] ) ) {
            throw new Error(`SyntaxError:  Column ${indexNo} not configured for Data Processing.`);
        }
        return this.TableOfVectors[indexNo];
    }

    pushTableRow(arrayA) {
        let i = 0;
        for ( let lvoe of this.TableOfVectors ) {
            if ( lvoe ) { 
                let buffer = Number(arrayA[i])
                if ( isNumber(buffer) ) lvoe.pushX(buffer);
                else                    return false;
            }
            i += 1;
        }
        return true;
    }

}
module.exports.VectorTable            = VectorTable;

//345678901234567890123456789012345678901234567890123456789012345678901234567890
// End of WPMS2023.js
