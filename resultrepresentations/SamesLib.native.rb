#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# SamesLib.native.rb - result representations are any transformation of a data
#   set to another, but most outstandingly, visual depictions.  Input parsing
#   includes parsing from one kind of output into objects for trannsformation to
#   another.

require 'csv'
require 'json'

#2345678901234567890123456789012345678901234567890123456789012345678901234567890

def isANumStr?(strA)
    return false    unless strA.is_a? String
    return false    unless strA =~ /^-?\d*\.?\d+$/
    return true
end

# NOTE:  need to decide how to share the utilities pieces of statisticsv1
def scootLeft(strA)
    raise ArgumentError unless strA.is_a? String
    buffer = strA.gsub(/^\s*/,'')
    return buffer
end

def throwUnlessKeyInAA(aaA,keyA,dataType=Numeric)
    unless aaA.has_key?(keyA)
        raise ArgumentError, "ERROR:  key '#{keyA}' not found in AA variable." 
    end
    buffer = aaA[keyA]
    if dataType.nil? then
        unless buffer.is_a?
        raise ArgumentError, "ERROR:  value at '#{keyA}' is not numeric."
    elsif dataType == Numeric then
        raise ArgumentError, "ERROR:  value at '#{keyA}' is not numeric."
    end
    return aaA[keyA] if aaA.has_key?(keyA)
end

class VectorOfResults

    class << self

        def newFromCSVLine()               raise ArgumentError, "Pure Virtual"; end
        def newFromHash()                  raise ArgumentError, "Pure Virtual"; end

    end

    CSVHeader   = "Must Be Implemented"
    HTMLHeader  = "Must Be Implemented"
    JSONTOPID   = "MustBeImplemented"
    LATEXTINIT  = "Must Be Implemented"

    LateXBarGraph   = 1
    LateXHistogram  = 2
    LateXPieChart   = 3
    LateXPlot       = 4
    LateXTable      = 5

    def _representDataInCSV()               raise ArgumentError, "Pure Virtual"; end
    def _representDataInHTML()              raise ArgumentError, "Pure Virtual"; end
    def _representDataInJSON()              raise ArgumentError, "Pure Virtual"; end
    def _representDataInLateXBarGraph()     raise ArgumentError, "Pure Virtual"; end
    def _representDataInLateXHistogram()    raise ArgumentError, "Pure Virtual"; end
    def _representDataInLateXPieChart()     raise ArgumentError, "Pure Virtual"; end
    def _representDataInLateXPlot()         raise ArgumentError, "Pure Virtual"; end
    def _representDataInLateXTable()        raise ArgumentError, "Pure Virtual"; end

    def initialize
        raise ArgumentError, "Pure Virtual"
    end

    def genCSV(includeHeader=true)
        csvrows = ""            unless includeCSVHeader
        csvrows = self::CSVHeader   if includeCSVHeader
        csvrows += _representDataInCSV
        return csvrows
    end

    def genHTML(reHeadPeriod=32)
        htmlrows = _representDataInHTML(reHeadPeriod)
        return <<-EOHTML
        <table border=1>
        #{self::HTMLHeader}
        #{htmlrows}
        </table>
        EOHTML
    end

    def genJSON
        jsonrows = _representDataInJSON
        return <<-EOJSON
        #{self::JSONTOPID} {
        #{jsonrows}
        }
        EOJSON
    end

    def genLateX(lItemType=LateXTable)
        # Note, I have a "scoot left" procedure to take out leading spaces,
        # as this point in processing is not concerning itself with speed.
        def genLateXBarGraphSimple
            datacontent = _representDataInLatexBarGraphSimple
            buffer = <<-EOLATEX
            EOLATEX
            b2 = scootLeft(buffer)
            return b2
        end
        def genLateXYBarStacked
            datacontent = _representDataInYBarStacked
            buffer = <<-EOLATEX
            \\begin{tikzpicture}
            \\begin{axis}[ybar stacked]
            #{datacontent}
            \\end{axis}
            \\end{tikzpicture}
            EOLATEX
            b2 = scootLeft(buffer)
            return b2
        end
        def genLateXHistogram
            datacontent = _representDataInLatexHistogram
            buffer = <<-EOLATEX
            EOLATEX
            b2 = scootLeft(buffer)
            return b2
        end
        def genLateXPieChart
            datacontent = _representDataInLatexPieChart
            buffer = <<-EOLATEX
            EOLATEX
            b2 = scootLeft(buffer)
            return b2
        end
        def genLateXOrderedPlot
            datacontent = _representDataInLatexOrderedPlot
            buffer = <<-EOLATEX
            EOLATEX
            b2 = scootLeft(buffer)
            return b2
        end
        def genLateXTable
            datacontent = _representDataInLatexTable
            buffer = <<-EOLATEX
            \\begin{tabular}{#{@TableSpecification}}
            #{datacontent}
            \\end{tabular}
            EOLATEX
            b2 = scootLeft(buffer)
            return b2
        end
        def genLateXUnOrderedPlot
            datacontent = _representDataInLatexUnOrderedPlot
            buffer = <<-EOLATEX
            EOLATEX
            b2 = scootLeft(buffer)
            return b2
        end
        latexrows = ""
        case lItemType
        when LateXBarGraphSimple
            latexrows = genLateXBarGraphSimple
        when LateXYBarStacked
            latexrows = genLateXYBarStacked
        when LateXHistogram
            latexrows = genLateXHistogramhttps://www.youtube.com/watch?v=331YxgOJUGw
        when LateXPieChart
            latexrows = genLateXPieChart
        when LateXOrderedPlot
            latexrows = genLateXOrderedPlot
        when LatexTable
            latexrows = genLateXTable
        when LateXUnorderedPlot
            latexrows = genLateXUnorderedPlot
        else
            raise ArgumentError, "This report type is not implemented."
        end
        return <<-EOLATEX
        #{LATEXINIT}
        #{latexrows}
        EOLATEX
    end

end

class PointStatistcisResults < VectorOfResults

    def initialize(isEven,maeA,maxA,meanA,medianA,minA,modeA,nA,sddP,sddS,sdsP,sdsS,sumA)

    IsEvenId            = 'Evenbool'
    MAEId               = 'MAE' # Mean Absolute Error
    MaxId               = 'Max'
    MeanId              = 'Mean'
    MedianId            = 'Median'
    MinId               = 'Min'
    ModeId              = 'Mode'
    NId                 = 'N'
    StddevDiffsPop      = 'StddevDiffsPop'
    StddevDiffsSample   = 'StddevDiffsSample'
    StddevSumxsPop      = 'StddevSumxsPop'
    StddevSumxsSample   = 'StddevSumxsSample'
    SumId               = 'Sum'

    CSVHeader   =
        "#{IsEvenId},#{MAEId},#{MaxId},#{MeanId},#{MedianId},#{MinId},#{ModeId},#{NId},#{StddevDiffsPopId},#{StddevDiffsSampleId},#{StddevSumxsPopId},#{StddevSumxsSampleId},#{SumId}"
    HTMLHeader  = "<tr><th>Statistic</th><th>Value</th></tr>"
    JSONTOPID = "PointStatsId"

    class << self

        def newFromArray(aA)
            (1..12).each do |i|
                unless aA[i].is_a? Numeric
                    raise ArgumentError, "Element #{i} of Point Statistic input array is not numeric."
                end
            end
            localo = self.new(aA[0],aA[1],aA[2],aA[3],aA[4],aA[5],aA[6],aA[7],aA[8],aA[9],aA[10],aA[11],aA[12])
            return localo
        end

        def newFromAA(aaA)
            localo = self.new(
                        throwUnlessKeyInAA(aaA,IsEvenId,nil),
                        throwUnlessKeyInAA(aaA,MAEId),
                        throwUnlessKeyInAA(aaA,MaxId),
                        throwUnlessKeyInAA(aaA,MeanId),
                        throwUnlessKeyInAA(aaA,MedianId),
                        throwUnlessKeyInAA(aaA,MinId),
                        throwUnlessKeyInAA(aaA,ModeId),
                        throwUnlessKeyInAA(aaA,NId),
                        throwUnlessKeyInAA(aaA,StddevDiffsPopId),
                        throwUnlessKeyInAA(aaA,StddevDiffsSampleId),
                        throwUnlessKeyInAA(aaA,StddevSumxsPopId),
                        throwUnlessKeyInAA(aaA,StddevSumxsSampleId),
                        throwUnlessKeyInAA(aaA,SumId)
                        )

        end

        def newFromStrCSV(csvLine)
            iseven,mae,max,mean,median,min,mode,n,sddp,sdds,sdsp,sdss,sum = csvLine.parse_csv
            localo = self.new(iseven,mae,max,mean,median,min,mode,n,sddp,sdds,sdsp,sdss,sum)
            return localo
        end

        def newFromStrHTMLTable(strA)
            strA    =~ /#{IsEvenId}<\/th><td>(\d+)</
            iseven  = $1.to_b
            strA    =~ /#{MAEId}<\/th><td>(\d*\.?\d+)</
            mae     = $1.to_f
            strA    =~ /#{MaxId}<\/th><td>(\d*\.?\d+)</
            max     = $1.to_f
            strA    =~ /#{MeanId}<\/th><td>(\d*\.?\d+)</
            mean    = $1.to_f
            strA    =~ /#{MedianId}<\/th><td>(\d*\.?\d+)</
            median  = $1.to_f
            strA    =~ /#{MinId}<\/th><td>(\d*\.?\d+)</
            min     = $1.to_f
            strA    =~ /#{ModeId}<\/th><td>(\d*\.?\d+)</
            mode    = $1.to_f
            strA    =~ /#{NId}<\/th><td>(\d+)</
            n       = $1.to_i
            strA    =~ /#{StddevDiffsPopId}<\/th><td>(\d*\.?\d+)</
            sddp    = $1.to_f
            strA    =~ /#{StddevDiffsSampleId}<\/th><td>(\d*\.?\d+)</
            sdds    = $1.to_f
            strA    =~ /#{StddevSumxsPopId}<\/th><td>(\d*\.?\d+)</
            sdsp    = $1.to_f
            strA    =~ /#{StddevSumxsSampleId}<\/th><td>(\d*\.?\d+)</
            sdss    = $1.to_f
            strA    =~ /#{SumId}<\/th><td>(\d+)</
            sum     = $1.to_i
            localo = self.new(iseven,mae,max,mean,median,min,mode,n,sddp,sdds,sdsp,sdss,sum)
            return localo
        end

        def newFromStrJSON(strA)
            jsono = JSON.parse(strA)
            localo = self.newFromAA(aaA)
            return localo
        end

        def newFromStrLateXTable
            raise ArgumentError, "NOTE:  TBD"
        end

    end

    def _representDataInCSV
        buffer = "#{@Mean},#{@Median},#{@Mode},#{@IsEven},#{@MinimumX},#{@MaximumX},"
        buffer += "#{@StdDevDiffsPopulation},#{@StdDevSumXsPopulation},#{@StdDevDiffsSample},#{@StdDevSumXsSample},"
        buffer += "#{@MeanAbsoluteError},#{@Sum},#{@N}"
        return buffer
    end

    def _representDataInHTML
        if sorted then
            return <<-EOROWS
            <tr>
                <th>MaximumX</th><td>#{@MaximumX}</td>
                <th>Mean</th><td>#{@MaximumX}</td>
                <th>MeanAbsoluteError</th><td>#{@MaximumX}</td>
                <th>Median</th><td>#{@MaximumX}</td>
                <th>Mode</th><td>#{@MaximumX}</td>
                <th>MinimumX</th><td>#{@MaximumX}</td>
                <th>N (Even?)</th><td>#{@MaximumX} (#{@IsEven})</td>
                <th>StdDevDiffsPopulation</th><td>#{@MaximumX}</td>
                <th>StdDevDiffsSample</th><td>#{@MaximumX}</td>
                <th>StdDevSumXsPopulation</th><td>#{@MaximumX}</td>
                <th>StdDevSumXsSample</th><td>#{@MaximumX}</td>
                <th>Sum</th><td>#{@MaximumX}</td>
            </tr>
            EOROWS
        else
            return <<-EOROWS
            <tr>
                <th>N (Even?)</th><td>#{@MaximumX} (#{@IsEven})</td>
                <th>Sum</th><td>#{@Sum}</td>
                <th>Mean</th><td>#{@Mean}</td>
                <th>Median</th><td>#{@Median}</td>
                <th>Mode</th><td>#{@Mode}</td>
                <th>Maximum</th><td>#{@MaximumX}</td>
                <th>Minimum</th><td>#{@MinimumX}</td>
                <th>MeanAbsoluteError</th><td>#{@MeanAbsoluteError}</td>
                <th>StdDevDiffsSample</th><td>#{@StdDevDiffsSample}</td>
                <th>StdDevSumXsSample</th><td>#{@StdDevSumXsSample}</td>
                <th>StdDevDiffsPopulation</th><td>#{@StdDevDiffsPopulation}</td>
                <th>StdDevSumXsPopulation</th><td>#{@StdDevSumXsPopulation}</td>
            </tr>
            EOROWS
        end
    end

    def _representDataInJSON
        return <<-EOROWS
            "IsEven": #{@IsEven},
            "MaximumX": #{@MaximumX},
            "Mean": #{@Mean},
            "MAE": #{@MeanAbsoluteError},
            "Median": #{@Median},
            "Mode": #{@Mode},
            "MinimumX": #{@MinimumX},
            "N": #{@N},
            "StdDevDiffsPop": #{@StdDevDiffsPopulation},
            "StdDevDiffsSample": #{@StdDevDiffsSample},
            "StdDevSumXsPop": #{@StdDevSumXsPopulation},
            "StdDevSumXsSample": #{@StdDevSumXsSample},
            "Sum": #{@Sum}
        EOROWS
    end

    def _representDataInLateXBarGraph
    end

    def _representDataInLateXHistogram
    end

    def _representDataInLateXPieChart
    end

    def _representDataInLateXPlot
    end

    def _representDataInLateXTable
    end

    def initialize(isEven,maeA,maxA,meanA,medianA,minA,modeA,nA,sddP,sddS,sdsP,sdsS,sumA)
        # At this point, presume the data is correct.  Validations are better done at the
        # points of parsing.
        @IsEven                 = isEven
        @MaximumX               = maxA
        @Mean                   = meanA
        @MeanAbsoluteError      = maeA
        @Median                 = medianA
        @MinimumX               = minA
        @Mode                   = modea
        @N                      = nA
        @StdDevDiffsPopulation  = sddP
        @StdDevDiffsSample      = sddS
        @StdDevSumXsPopulation  = sdsP
        @StdDevSumXsSample      = sdsS
        @Sum                    = sumA
    end

end

class QuartileResults < VectorOfResults

    CSVHeader = "Minimum,Quartile 1,Median,Quartile 3,Maximum"
    HTMLHeader =<<-EOHDR
    <tr>
    <th>Quartile</th>
    <th>Value</th>
    </tr>
    EOHDR
    JSONTOPID = "QuartileId"

    class << self

        def newFromArray
            localo = self.new(aA[0],aA[1],aA[2],aA[3],aA[4],aA[5],aA[6],aA[7],aA[8],aA[9],aA[10],aA[11],aA[12])
            return localo
        end

        def newFromCSV(lineNo=1)
        end

        def newFromHash
        end

        def newFromHTMLTable
        end

        def newFromJSON(elementNo=0)
        end

        def newFromLateXTable
        end

    end

    def _representDataInCSV
        min,q1,q2,q3,max = @QuartileArray
        return "#{min},#{q1},#{q2},#{q3},#{max}\n"
    end

    def _representDataInHTML
        return <<-EOROWS
        <tr><th>Minimum</th><td>#{@QuartileArray[0]}</td></tr>
        <tr><th>First</th><td>#{@QuartileArray[1]}</td></tr>
        <tr><th>Median</th><td>#{@QuartileArray[2]}</td></tr>
        <tr><th>Third</th><td>#{@QuartileArray[3]}</td></tr>
        <tr><th>Maximum</th><td>#{@QuartileArray[4]}</td></tr>
        EOROWS
    end

    def _representDataInJSON
        return <<-EOROWS
            "Minimum":  #{@QuartileArray[0]},
            "First":    #{@QuartileArray[1]},
            "Median":   #{@QuartileArray[2]},
            "Third<":   #{@QuartileArray[3]},
            "Maximum":  #{@QuartileArray[4]}
        EOROWS
    end

    def _representDataInLateXBarGraph
    end

    def _representDataInLateXHistogram
    end

    def _representDataInLateXPieChart
    end

    def _representDataInLateXPlot
    end

    def _representDataInLateXTable
    end

    def initialize(quartileA)
        raise ArgumentError, "Argument must be an array."   unless quartileA.is_a? Array
        raise ArgumentError, "Argument have 5 elements."    unless quartileA.size == 5
        i = 0
        quartileA.each do |lqst|
            unless lqst.is_a? Numeric
                raise ArgumentError, "Quartile #{i} Statistic Argument is NOT numeric."
            end
            if i < 4 then
                unless lqst <= quartileA[i+1]
                    m = "Bad Order for Quartile values for #{i}(#{lqst}) and #{i+1}( #{quartileA[i+1]})."
                    raise ArgumentError, m
                end
            end
            i += 1
        end
        @QuartileArray = quartileA
    end

end

class FrequenciesResuls < VectorOfResults

    CSVHeader = "Value,Frequency"
    HTMLHeader =<<-EOHDR
    <tr>
        <th>Value</th>
        <th>Frequency</th>
    </tr>
    EOHDR
    JSONTOPID = "FrequenciesId"

    class << self

        def newFromArray
        end

        def newFromCSV(lineNo=1)
        end

        def newFromHash
        end

        def newFromHTMLTable
        end

        def newFromJSON(elementNo=0)
        end

        def newFromLateXTable
        end

    end

    def _representDataInCSV
        def genElement(lValue)
            return <<-EOFREQ
            <tr>
                <th>#{lValue}</th>
                <td>#{@FrequencyHash[lValue]}</td>
            </tr>
            EOFREQ
        end
        csvrows = ""
        @FrequencyHash.keys.sort.each do |lvalue|
            csvrows += "\"#{lvalue}\",#{@FrequencyHash[lvalue]}"
        end
        return csvrows
    end

    def _representDataInHTML
        def genElement(lValue)
            return <<-EOFREQ
            <tr>
                <th>#{lValue}</th>
                <td>#{@FrequencyHash[lValue]}</td>
            </tr>
            EOFREQ
        end
        htmlrows = ""
        @FrequencyHash.keys.sort.each do |lvalue|
            htmlrows += genElement(lvalue)
        end
        return htmlrows
    end

    def _representDataInJSON
        def genElement(valStr,freqA)
            return <<-EOElement
            {
                value: #{valStr};
                frequency: #{freqA};
            }
            EOElement
        end
        jsonstr = ""
        @FrequenciesHash.keys.each do |lxv|
            jsonstr += genElement(lxv,@FrequenciesHash[lxv])
        end
        return jsonstr
    end

    def _representDataInLateXBarGraph
    end

    def _representDataInLateXHistogram
    end

    def _representDataInLateXPieChart
    end

    def _representDataInLateXPlot
    end

    def _representDataInLateXTable
    end

    def initialize(frequenciesHash)
        @FrequenciesHash = frequenciesHash
    end

end

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# End of SamesLib.native.rb
