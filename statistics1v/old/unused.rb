def returnIfThere(fSpec)
    return fSpec if File.exists?(fSpec)
    raise ArgumentError, "Test data file #{fSpec} not found." 
end

SamesDs=File.expand_path("../..", __dir__)
TestDataDs="#{SamesDs}/testdata"

FirstTestFileFs=returnIfThere("#{TestDataDs}/doexampledata.sorted.reversed.truncated1024.csv")

    it "Has a method to display elements for manual examination." do
        a = [1.5,99,5876.1234,"String",String]
        localo = VectorOfX.new(a)
        assert_respond_to localo, :listVectorElementsForVisualExamination
        $stdout = StringIO.new
        result = localo.listVectorElementsForVisualExamination
        $stdout = STDOUT
        assert result.size > 0
        $stderr = StringIO.new
        result = localo.listVectorElementsForVisualExamination(true)
        $stderr = STDERR
        assert result.size > 0
    end

    def listVectorElementsForVisualExamination(toStdError=false)
        i = 0
        @VectorOfX.each do |lx|
            puts        "Element[#{i}]:  #{lx}" unless toStdError
            STDERR.puts "Element[#{i}]:  #{lx}"     if toStdError
            i += 1
        end
    end


    def _genHistogramInitialAA(startNo,segmentSize)
        # xc 20231106:  Don't worry about cost of passing the AA around until efficiency passes later.
        bottomno    = startNo
        lrsaa       = Hash.new
        topno       = bottomno + segmentSize
        max         = genMax
        while bottomno < max
            rangea          = [bottomno,topno]
            lrsaa[rangeo]   = 0
            bottomno        = topno
            topno           += segmentSize
        end
        return lrsaa
    end

