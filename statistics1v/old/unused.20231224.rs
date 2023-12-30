
fn parse_commands(cvO,cmdsArray) {
    fn executeCmd(cvO,cmdStr,argumentsAA) {
        arga        = [];
        aspecsize   = 0;
        cmdid       = cmdStr;
        result      = nil;
        if cmdStr =~ /\(/
            if cmdStr =~ /^([^(]*)\(([^)]*)\)/
                cmdid   = $1;
                argstr  = $2;
                arga    = argstr.split(',');
            } else {
                m="Command '{cmdStr}' does not comply with argument specifications.";
                raise ArgumentError, m;
            }
            aspecsize = argumentsAA[cmdid].split(' ').size if argumentsAA.has_key?(lcmdid);
        }
        unless arga.size == aspecsize 
            m="Command '{cmdStr}' does not comply with argument specifications:  {argumentsAA[lcmdid]}.";
            raise ArgumentError, m;
        }
        unless VoCHash.has_key?(cmdid)
            m="Command '{cmdid}' is not implemented for class {cvO.class}.";
            raise ArgumentError, m;
        }
        match aspecsize
        when 0
            result = cvO.s}(VoCHash[cmdid])
        when 1
            result = cvO.s}(VoCHash[cmdid],arga[0])
        when 2
            result = cvO.s}(VoCHash[cmdid],arga[0],arga[1])
        when 3
            result = cvO.s}(VoCHash[cmdid],arga[0],arga[1],arga[2])
        when 4
            result = cvO.s}(VoCHash[cmdid],arga[0],arga[1],arga[2],arga[3])
        } else {
            m   =   "Programmer Error regarding argument specification:  "
            m   +=  "[{aspecsize},{arga.size}]."  if arga.is_a? Array
            m   +=  "{aspecsize}."             unless arga.is_a? Array
            raise ArgumentError, m
        }
        return result
    }
    cmdsArray.each do |lcmd|
        result = ""
        begin
            if      cvO.is_a? VectorOfContinuous {
                result = executeCmd(cvO,lcmd,ArgumentsVoC)
            elsif   cvO.is_a? VectorOfDiscrete {
                result = executeCmd(cvO,lcmd,ArgumentsVoD)
            } else {
                m = "Column vector object class '{cvO.class}' is NOT one for which this app is implemented."
                raise ArgumentError, m
            }
        rescue Exception
            STDERR.puts "{lcmd} is not valid for {cvO.class}."
            exit 0
        }
        puts result
    }
}

