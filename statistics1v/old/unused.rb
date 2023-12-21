    pub fn load_from_str_vector(&mut self,vector_of_x: Vec<&str>,on_bad_data: BadDataAction) {
        for lx in vector_of_x.iter() {
            self.push_x_string(lx.to_string(),on_bad_data)?;
        }
    }

    pub fn load_from_string_vector(&mut self,vector_of_x: Vec<String>,on_bad_data: BadDataAction) {
        for lx in vector_of_x.iter() {
            self.push_x_string(*lx,on_bad_data)?;
        }
    }

    fn new() -> Self {
        let buffer: VectorOfDiscrete = Default::default();
        return buffer;
    }

    fn new_from_str_after_invalidated_dropped(vector_of_x: Vec<&str>) -> Self {
        let mut buffer: VectorOfDiscrete = Default::default();
        for lx in vector_of_x.iter() {
            if lx.len() > 0 {
                // Always skip data item by definition.
                buffer.push_x_str(lx,SKIPDATAITEM).unwrap();
            }
        }
        return buffer;
    }

    fn new_from_string_after_invalidated_dropped(vector_of_x: Vec<String>) -> Self {
        let mut buffer: VectorOfDiscrete = Default::default();
        for lx in vector_of_x.iter() {
            if lx.len() > 0 {
                // Always skip data item by definition.
                buffer.push_x_string(lx.to_string(),SKIPDATAITEM).unwrap();
            }
        }
        return buffer;
    }

impl CreationistVectorX for VectorOfContinuous {

    fn new() -> Self {
        let buffer: VectorOfContinuous = Default::default();
        return buffer;
    }

    fn new_from_str_after_invalidated_dropped(vector_of_x: Vec<&str>) -> Self {
        let mut buffer: VectorOfContinuous = Default::default();
        for lx in vector_of_x.iter() {
            // Need to remove or justify the unwrap here:
            if is_a_num_str(lx) {
                buffer.push_x_str(lx,SKIPDATAITEM).unwrap();
            }
        }
        return buffer;
    }

    fn new_from_string_after_invalidated_dropped(vector_of_x: Vec<String>) -> Self {
        let mut buffer: VectorOfContinuous = Default::default();
        for lx in vector_of_x.iter() {
            // Need to remove or justify the unwrap here:
            if is_a_num_str(lx.as_str()) {
                buffer.push_x_str(lx,SKIPDATAITEM).unwrap();
            }
        }
        return buffer;
    }

}

impl CreationistVectorOfContinuous for VectorOfContinuous {

    pub fn new_from_f64(vector_of_x: Vec<f64>) -> Self {
        let mut buffer: VectorOfContinuous = Default::default();
        for lx in vector_of_x.iter() {
            buffer.push_x(*lx);
        }
        return buffer;
    }

    pub fn new_from_i32(vector_of_x: Vec<i32>) -> Self {
        let mut buffer: VectorOfContinuous = Default::default();
        for lx in vector_of_x.iter() {
            buffer.push_x(*lx as f64);
        }
        return buffer;
    }

    pub fn new_from_str_vector(vector_of_x: Vec<&str>,on_bad_data: BadDataAction) -> Result<VectorOfContinuous, ValidationError> {
        let mut buffer: VectorOfContinuous = Default::default();
        for lx in vector_of_x.iter() {
            buffer.push_x_str(lx,on_bad_data)?;
        }
        return Ok(buffer);
    }

    pub fn new_from_string_vector(vector_of_x: Vec<String>,on_bad_data: BadDataAction) -> Result<VectorOfContinuous, ValidationError> {
        let mut buffer: VectorOfContinuous = Default::default();
        for lx in vector_of_x.iter() {
            buffer.push_x_string(lx.to_string(),on_bad_data)?;
        }
        return Ok(buffer);
    }

}

impl CreationistVectorOfDiscrete for VectorOfDiscrete {

    /* NOTE:  This follows one of many areas of duplicated code
        which I have NOT yet figured out how to put into a unique
        area like a trait.
     */  
    pub fn new_from_str_number_vector(vector_of_x: Vec<&str>,on_bad_data: BadDataAction) -> Result<VectorOfDiscrete, ValidationError> {
        let mut buffer: VectorOfDiscrete = Default::default();
        for lx in vector_of_x.iter() {
            buffer.push_x_str(lx,on_bad_data)?;
        }
        return Ok(buffer);
    }

    pub fn new_from_string_number_vector(vector_of_x: Vec<String>,on_bad_data: BadDataAction) -> Result<VectorOfDiscrete, ValidationError> {
        let mut buffer: VectorOfDiscrete = Default::default();
        for lx in vector_of_x.iter() {
            buffer.push_x_string(lx.to_string(),on_bad_data)?;
        }
        return Ok(buffer);
    }

}

trait CreationistVectorOfContinuous : CreationistVectorOfX {
    pub fn new_from_f64(vector_of_x: Vec<f64>) -> Self;
    pub fn new_from_i32(vector_of_x: Vec<i32>) -> Self;
    pub fn new_from_str_vector(vector_of_x: Vec<&str>,on_bad_data: BadDataAction) -> Result<VectorOfContinuous, ValidationError>;
    pub fn new_from_string_vector(vector_of_x: Vec<String>,on_bad_data: BadDataAction) -> Result<VectorOfContinuous, ValidationError>;
}

trait CreationistVectorOfDiscrete : CreationistVectorOfX {
    pub fn new_from_str_vector(vector_of_x: Vec<&str>,on_bad_data: BadDataAction) -> Result<VectorOfDiscrete, ValidationError>;
    pub fn new_from_string_vector(vector_of_x: Vec<String>,on_bad_data: BadDataAction) -> Result<VectorOfDiscrete, ValidationError>;
}

pub trait CreationistVectorOfX : VectorOfX {
    fn new() -> Self;
    fn new_from_str_after_invalidated_dropped(vector_of_x: Vec<&str>) -> Self;
    fn new_from_string_after_invalidated_dropped(vector_of_x: Vec<String>) -> Self;
}


    /*
    fn _parse_csv_string(data_string: String) -> Result<Vec<String>,ValidationError> {
        let mut rdr = ReaderBuilder::new().from_reader(data_string.as_bytes());

        let records = match rdr 
            .records()
            .collect::<Result<Vec<StringRecord>, csv::Error>>() {
            Ok(b)       => b,
            Err(_err)   => {
                let m = "parse by ReaderBuilder of csv data error.".to_string();
                return Err(ValidationError::ArgumentError(m));
            },
        };
        let vb: Vec<String> = Vec::new();
        for lstr in records.iter() {
            vb.push(lstr.to_string());
        }
        return Ok(vb);
    }

    fn example() -> Result<(), Box<dyn Error>> {
        // Build the CSV reader and iterate over each record.
        let mut rdr = csv::Reader::from_reader(io::stdin());
        for result in rdr.records() {
            // The iterator yields Result<StringRecord, Error>, so we check the
            // error here.
            let record = result?;
            println!("{:?}", record);
        }
        Ok(())
    }

    fn _parse_csv_string(data_string: String) -> Option<Vec<String>> {
        let mut iterable =
            ReaderBuilder::new().delimiter(b',').from_reader(data_string.as_bytes());
        if let Some(result) = iterable.records().next() {
            let vb: Vec<String> = Vec::new();
            for lstr in result.iter() {
                //vb.push(lstr.to_string());
                vb.push(lstr);
            }
            return Some(vb);
        }
        return None;
    }
     */

