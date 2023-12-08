
    fn _from_f64_to_i128(&self,subject_float: f64) -> i128 {
        let base: f64           = 10.0;
        let precision_base: f64 = base.powi( self.in_precision );
        let buffer: i128         = ( subject_float * precision_base ).round();
        return buffer;
    }

    fn _from_i128_to_f64(&self,integer: i128) -> f64 {
        let base: f64           = 10.0;
        let precision_base: f64 = base.powi( precision_digits );
        let newfloat            = subject_integer as f64 / precision_base;
        return newfloat;
    }

