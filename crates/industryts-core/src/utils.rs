//! Utility functions

/// Helper functions for time series processing
pub fn columns_or_default(columns: Option<&[String]>, default: &[String]) -> Vec<String> {
    columns
        .map(|cols| cols.to_vec())
        .unwrap_or_else(|| default.to_vec())
}
