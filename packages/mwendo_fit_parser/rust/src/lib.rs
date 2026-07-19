use std::ffi::{CStr, CString};
use std::os::raw::c_char;

#[no_mangle]
pub extern "C" fn parse_fit_data(path: *const c_char) -> *mut c_char {
    if path.is_null() {
        return std::ptr::null_mut();
    }
    let c_str = unsafe { CStr::from_ptr(path) };
    let path_str = match c_str.to_str() {
        Ok(s) => s,
        Err(_) => return std::ptr::null_mut(),
    };
    
    // ponytail: mock parsing for scaffolding. In Phase 1, we will integrate the actual fitparser crate.
    let mock_json = format!("{{\"path\": \"{}\", \"status\": \"scaffolded\"}}", path_str);
    let c_string = CString::new(mock_json).unwrap();
    c_string.into_raw()
}

#[no_mangle]
pub extern "C" fn free_string(ptr: *mut c_char) {
    if !ptr.is_null() {
        unsafe {
            let _ = CString::from_raw(ptr);
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_works() {
        let path = CString::new("test.fit").unwrap();
        let ptr = parse_fit_data(path.as_ptr());
        assert!(!ptr.is_null());
        let result_c_str = unsafe { CStr::from_ptr(ptr) };
        let result_str = result_c_str.to_str().unwrap();
        assert!(result_str.contains("scaffolded"));
        free_string(ptr);
    }
}
