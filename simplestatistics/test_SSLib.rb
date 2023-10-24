#!/usr/bin/ruby

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# test_WPMS2023.rb

=begin
# TBD:
1.  Quartiles and mode are not that important to me right now, and both appear
to be broken, so putting that off until later.
2.  Generate JSON and CSV output from Vector Base class.
3.  Program draft of discrete class 
4.  Maybe leave most things undone until the primaries are all covered.
=end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Constants and Includes

require 'rspec/autorun'
require 'rspec/core'
require 'test/unit'

require_relative 'WPMS2023.rb'

include Test::Unit::Assertions

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# Tests

describe 'isANumStr?' do

    it "Discerns if value has a String that could be parsed as a number." do
        result = isANumStr?('1234')
        assert result == true
        result = isANumStr?('1234.56789')
        assert result == true
        result = isANumStr?('.1234')
        assert result == true
        result = isANumStr?('1234.0')
        assert result == true
        result = isANumStr?('12 34')
        assert result == false
        result = isANumStr?('12x4')
        assert result == false
        result = isANumStr?('A')
        assert result == false
        result = isANumStr?('%')
        assert result == false
    end

    it "Rejects non-strings." do
        result = isANumStr?(1234)
        assert result == false
        v = 15.993
        result = isANumStr?(v)
        assert result == false
        v = 0.1234
        result = isANumStr?(v)
        assert result == false
    end

end

describe 'isNumericVector?' do

    it "It discerns whether all elements of a vector are good numbers for data." do
        assert isNumericVector?([1,2,3,4,5]) == true
        assert isNumericVector?(['1',2,'33.33',"4"]) == false
        assert isNumericVector?(['1',2]) == false
        assert isNumericVector?([2,'33.33']) == false
        assert isNumericVector?(["4",5,6]) == false
        assert isNumericVector?([2,33.33,0004,0x5,12341234123412341234]) == true
        assert isNumericVector?(['x',2,3,4,5]) == false
        assert isNumericVector?([' 1 1 ',2,3,4,5]) == false
    end

end

describe 'isUsableNumber?' do

    it "Accepts any number or string that can be parsed as a number." do
        result = isUsableNumber?(1234)
        assert result == true
        v = 15.993
        result = isUsableNumber?(v)
        assert result == true
        v = 0.1234
        result = isUsableNumber?(v)
        assert result == true
        result = isUsableNumber?('1234')
        assert result == true
        result = isUsableNumber?('1234.56789')
        assert result == true
        result = isUsableNumber?('.1234')
        assert result == true
        result = isUsableNumber?('1234.0')
        assert result == true
    end

    it "Rejects non-numeric stuff." do
        result = isUsableNumber?('%')
        assert result == false
        result = isUsableNumber?('12 34')
        assert result == false
        result = isUsableNumber?('12x4')
        assert result == false
        result = isUsableNumber?('A')
        assert result == false
        v = /blek/
        result = isUsableNumber?(v)
        assert result == false
        v = Hash.new
        result = isUsableNumber?(v)
        assert result == false
    end

end

describe "isUsableNumberVector?" do

    it "It discerns whether all elements of a vector are good numbers for data." do
        assert isUsableNumberVector?([1,2,3,4,5]) == true
        assert isUsableNumberVector?(['1',2,'33.33',"4"]) == true
        assert isUsableNumberVector?(['1',2]) == true
        assert isUsableNumberVector?([2,'33.33']) == true
        assert isUsableNumberVector?(["4",5,6]) == true
        assert isUsableNumberVector?([2,33.33,0004,0x5,12341234123412341234]) == true
        assert isUsableNumberVector?(['x',2,3,4,5]) == false
        assert isUsableNumberVector?([' 1 1 ',2,3,4,5]) == false
    end

end

describe VectorOfContinuous do

    it "Constructs with no argument." do
        assert_nothing_raised do
            VectorOfContinuous.new
        end
        localo = VectorOfContinuous.new
        assert localo.is_a? VectorOfContinuous
        localo.pushX(5.333)
    end

    it "Constructs with a Ruby Array." do
        assert_nothing_raised do
            VectorOfContinuous.new([1.5,99,5876.1234])
        end
        localo = VectorOfContinuous.new([99.336,5.9,0x259,88441133.7,1234])
        assert localo.is_a? VectorOfContinuous
    end

    it "Provides a number of useful calculations." do
        a0  = [0,1,2,3,4,5,6,7,8,9]
        a1  = [0.0,1.1,2.2,3.3,4.4,5.5,6.6,7.7,8.8,9.9]
        a2  = [99.336,5.9,0x259,88441133.7,1234,1.5,99,5876.1234]
        l0o = VectorOfContinuous.new(a0)
        mu = l0o.genMean
        assert mu == 4.5
        msd = l0o.genMeanStdDev
        #STDERR.puts "trace msd:  #{msd}"
        assert msd == 3.0277
        med = l0o.genMedian
        assert med == 5
        #STDERR.puts "trace med:  #{med}"
        mod = l0o.genMode
        #assert mod == 0 # Mode result seems wrong, so I need to revisit the calculation.  Probably needs an ending mean.
        #STDERR.puts "trace mod:  #{mod}"
        qua = l0o.genQuartiles
        assert qua.is_a? Array
        assert qua.size == 5
        #STDERR.puts "trace quartiles:  #{qua}" # and Quartiles look wrong too.
        l1o = VectorOfContinuous.new(a1)
        l2o = VectorOfContinuous.new(a2)
    end

end

describe VectorOfDiscrete do
    it "Accepts any number or string that can be parsed as a number." do
    end
end

describe VectorTable do
# Primary Example:  ./testdata/doexampledata.csv
#year_month,month_of_release,passenger_type,direction,sex,age,estimate,standard_error,status
#2001-01,2020-09,Long-term migrant,Arrivals,Female,0-4 years,344,0,Final

    it "Constructs with just a class/column argument." do
           #2001-01,2020-09,Long-term migrant,Arrivals,Male,0-4 years,341,0,Final
        vcsa = [nil,nil,nil,nil,nil,nil,VectorOfContinuous,VectorOfContinuous,nil]
        assert_nothing_raised do
            VectorTable.new(vcsa)
        end
        localo = VectorTable.new(vcsa)
        assert localo.is_a? VectorTable
    end
    
    it "Allows adding a data row's of vector elements." do
           #2001-01,2020-09,Long-term migrant,Arrivals,Male,0-4 years,341,0,Final
        vcsa = [nil,nil,nil,nil,nil,nil,VectorOfContinuous,VectorOfContinuous,nil]
        localo = VectorTable.new(vcsa)
        a = ['Nil0','Nil1','Nil2','Nil3','Nil4','Nil5',123456,77,'Nil8']
        localo.pushTableRow(a)
        lvi6o = localo.getVectorObject(6)
        assert lvi6o.is_a? VectorOfContinuous
        lvi7o = localo.getVectorObject(7)
        assert lvi7o.is_a? VectorOfContinuous
    end

    it "Allows a user to load column values from a CSV file (and make all the calculations on vectors filled)." do
           #2001-01,2020-09,Long-term migrant,Arrivals,Male,0-4 years,341,0,Final
        fspec   = 'testdata/doexampledata.csv'
        vcsa    = [nil,nil,nil,nil,nil,nil,VectorOfContinuous,VectorOfContinuous,nil]
        localo  = VectorTable.newFromCSV(fspec,vcsa)
        lvi6o = localo.getVectorObject(6)
        mu = lvi6o.genMean
        msd = lvi6o.genMeanStdDev
        #STDERR.puts "trace mu:  #{mu}"
        #STDERR.puts "trace msd:  #{msd}"
        assert mu == 437.2062
        assert msd == 1195.4808
        lvi7o = localo.getVectorObject(7)
        mu = lvi7o.genMean
        msd = lvi7o.genMeanStdDev
        #STDERR.puts "trace mu:  #{mu}"
        #STDERR.puts "trace msd:  #{msd}"
        assert mu == 0.5492
        assert msd == 4.0465
    end

end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# End of test_WPMS2023.rb
