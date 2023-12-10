
        if self._n_zero() {
            return Ok(None);
        }
        let option      = self.request_summary_collection()?;
        let scaa        = match option {
            None            => return Ok(None),
            Some(aabuffer)  => aabuffer,
        };
        let result      = serde_json::to_string(&scaa);
        let jsonstring  = match result {
            Err(_err)     => return Err(ValidationError::ArgumentError("Problem with json parsing".to_string())),
            Ok(aabuffer)  => aabuffer,
        };
