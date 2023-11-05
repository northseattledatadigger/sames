
    def genAllStatisticsHTMLTable
        sa = genAllStatistics
        return <<-EOHTML
        <table border=1>
        <tr><th>Statistic</th><th>Value</th></tr>
        <tr><th>Mean</th><td>#{sa[0]}</td></tr>
        <tr><th>Median</th><td>#{sa[1]}</td></tr>
        <tr><th>Mode</th><td>#{sa[2]}</td></tr>
        <tr><th>EvenBool</th><td>#{sa[3]}</td></tr>
        <tr><th>Min</th><td>#{sa[4]}</td></tr>
        <tr><th>Q1</th><td>#{sa[5]}</td></tr>
        <tr><th>Q2</th><td>#{sa[6]}</td></tr>
        <tr><th>Q3</th><td>#{sa[7]}</td></tr>
        <tr><th>Max</th><td>#{sa[8]}</td></tr>
        <tr><th>PopStdDevDiffs</th><td>#{sa[9]}</td></tr>
        <tr><th>PopStdDevSumXs</th><td>#{sa[10]}</td></tr>
        <tr><th>SampleStdDevDiffs</th><td>#{sa[11]}</td></tr>
        <tr><th>SampleStdDevSumXs</th><td>#{sa[12]}</td></tr>
        <tr><th>MAE</th><td>#{sa[13]}</td></tr>
        <tr><th>Sum</th><td>#{sa[14]}</td></tr>
        </table>
        EOHTML
    end

    def genAllStatisticsJSON
        sa = genAllStatistics
        return <<-EOJSON
        allStatistics [
            "Mean":  #{sa[0]},
            "Median":  #{sa[1]},
            "Mode":  #{sa[2]},
            "EvenBool":  #{sa[3]},
            "Min":  #{sa[4]},
            "Q1":  #{sa[5]},
            "Q2":  #{sa[6]},
            "Q3":  #{sa[7]},
            "Max":  #{sa[8]},
            "PopStdDevDiffs":  #{sa[9]},
            "PopStdDevSumXs":  #{sa[10]},
            "SampleStdDevDiffs":  #{sa[11]},
            "SampleStdDevSumXs":  #{sa[12]},
            "MAE":  #{sa[13]},
            "Sum":  #{sa[14]}
        ]
        EOJSON
    end

