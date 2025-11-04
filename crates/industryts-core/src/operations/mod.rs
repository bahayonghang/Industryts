//! Time series operations module
//!
//! This module provides various operations for time series data processing:
//! - Cleaning: data cleaning and null handling
//! - Time: time-based operations like resampling (TODO: needs Polars 0.51 API update)
//! - Features: feature engineering operations like lag and rolling
//! - Transform: data transformation operations like standardization

pub mod cleaning;
// pub mod time;  // TODO: Resample needs Polars 0.51 API update
pub mod features;
pub mod transform;

// Re-export operation implementations
pub use cleaning::*;
// pub use time::*;  // TODO: Resample needs Polars 0.51 API update
pub use features::LagOperation;
pub use transform::*;
