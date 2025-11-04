//! Industryts Core Library
//!
//! High-performance time series processing library powered by Polars.

pub mod error;
pub mod timeseries;
pub mod pipeline;
pub mod config;
pub mod operations;
pub mod utils;

// Re-export main types
pub use error::{IndustrytsError, Result};
pub use timeseries::TimeSeriesData;
pub use pipeline::{Pipeline, Operation};
pub use config::PipelineConfig;
