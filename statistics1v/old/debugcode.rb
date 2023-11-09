STDERR.puts "trace 0 a:  #{a}"
STDERR.puts "trace 1 hdaa:  #{hdaa}"
STDERR.puts "trace 2 hdaa:  #{hdaa}"

        STDERR.puts "trace 3a genVarianceUsingSubjectAsDiffs NF: #{nf} (#{@N})"
        STDERR.puts "trace 3b genVarianceUsingSubjectAsDiffs Population Boolean: #{@Population}"
        STDERR.puts "trace 3c genVarianceUsingSubjectAsDiffs Sum of (xi - amean) Squared:  #{@SumPowerOf2}"
        STDERR.puts "trace 3d genVarianceUsingSubjectAsDiffs: #{v} == diffsquaredsums / nf "              if @Population
        STDERR.puts "trace 3d genVarianceUsingSubjectAsDiffs: #{v} == diffsquaredsums / ( nf - 1.0 ) "    unless @Population

        STDERR.puts "trace 9a genVarianceUsingSubjectAsDiffs NF: #{nf}"
        STDERR.puts "trace 9b genVarianceUsingSubjectAsDiffs Population Boolean: #{@Population}"
        STDERR.puts "trace 9c genVarianceUsingSubjectAsDiffs Sum of Xs Squared:  #{@SumPowerOf2}"
        STDERR.puts "trace 9d genVarianceUsingSubjectAsSumXs AMean:  #{@ArithmeticMean}"
        STDERR.puts "trace 9e genVarianceUsingSubjectAsSumXs AMean Squared:  #{ameansquared}"
        STDERR.puts "trace 9f genVarianceUsingSubjectAsDiffs: #{v} == sumofxsxqured - nf * ameansquared / nf"                if @Population
        STDERR.puts "trace 9g genVarianceUsingSubjectAsDiffs: #{v} == sumofxsxqured - nf * ameansquared / ( nf - 1.0 )"  unless @Population
