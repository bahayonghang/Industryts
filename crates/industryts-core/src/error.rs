//! Error types for industryts-core

use thiserror::Error;

/// Result type for industryts operations
pub type Result<T> = std::result::Result<T, IndustrytsError>;

/// Main error type for the library
#[derive(Error, Debug)]
pub enum IndustrytsError {
    #[error("Time column not found: {0}")]
    TimeColumnNotFound(String),

    #[error("Invalid time column type: expected datetime, found {0}")]
    InvalidTimeColumnType(String),

    #[error("Column not found: {0}")]
    ColumnNotFound(String),

    #[error("Invalid operation: {0}")]
    InvalidOperation(String),

    #[error("Operation error: {0}")]
    OperationError(String),

    #[error("Configuration error: {0}")]
    ConfigError(String),

    #[error("Polars error: {0}")]
    PolarsError(#[from] polars::prelude::PolarsError),

    #[error("TOML parsing error: {0}")]
    TomlError(#[from] toml::de::Error),

    #[error("IO error: {0}")]
    IoError(#[from] std::io::Error),
}
