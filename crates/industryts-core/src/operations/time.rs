//! Time-based operations for time series data

use crate::error::Result;
use crate::timeseries::TimeSeriesData;
use crate::pipeline::Operation;
use crate::config::AggMethod;
use polars::prelude::*;

/// Resample operation - convert time series to different frequency
pub struct ResampleOperation {
    rule: String,
    aggregation: AggMethod,
    columns: Option<Vec<String>>,
}

impl ResampleOperation {
    pub fn new(rule: String, aggregation: AggMethod, columns: Option<Vec<String>>) -> Self {
        Self {
            rule,
            aggregation,
            columns,
        }
    }

    /// Parse time rule string (e.g., "10min", "1h", "1d") to Duration
    fn parse_rule(&self) -> Result<Duration> {
        let rule = self.rule.trim();

        // Extract number and unit
        let (num_str, unit) = rule.split_at(
            rule.chars()
                .position(|c| !c.is_numeric())
                .unwrap_or(rule.len())
        );

        let num: i64 = num_str.parse()
            .map_err(|_| crate::IndustrytsError::ConfigError(
                format!("Invalid rule format: {}", self.rule)
            ))?;

        let duration = match unit.to_lowercase().as_str() {
            "s" | "sec" | "second" | "seconds" => Duration::parse(&format!("{}s", num)),
            "min" | "minute" | "minutes" => Duration::parse(&format!("{}m", num)),
            "h" | "hour" | "hours" => Duration::parse(&format!("{}h", num)),
            "d" | "day" | "days" => Duration::parse(&format!("{}d", num)),
            "w" | "week" | "weeks" => Duration::parse(&format!("{}w", num)),
            "" if num > 0 => Duration::parse(&format!("{}s", num)), // Default to seconds
            _ => return Err(crate::IndustrytsError::ConfigError(
                format!("Unsupported time unit in rule: {}", self.rule)
            )),
        };

        Ok(duration)
    }

    /// Get aggregation expression based on method
    fn get_agg_expr(&self, col_name: &str) -> Expr {
        let col_expr = col(col_name);

        match self.aggregation {
            AggMethod::Mean => col_expr.mean(),
            AggMethod::Sum => col_expr.sum(),
            AggMethod::Min => col_expr.min(),
            AggMethod::Max => col_expr.max(),
            AggMethod::First => col_expr.first(),
            AggMethod::Last => col_expr.last(),
            AggMethod::Count => col_expr.count(),
        }
    }
}

impl Operation for ResampleOperation {
    fn execute(&self, data: TimeSeriesData) -> Result<TimeSeriesData> {
        let time_col = data.time_column();

        // Get columns to aggregate
        let columns_to_agg = if let Some(cols) = &self.columns {
            cols.clone()
        } else {
            data.feature_columns().to_vec()
        };

        // Parse duration
        let duration = self.parse_rule()?;

        // Create lazy frame for efficient computation
        let lf = data.dataframe().clone().lazy();

        // Build aggregation expressions
        let agg_exprs: Vec<Expr> = columns_to_agg
            .iter()
            .map(|col_name| self.get_agg_expr(col_name))
            .collect();

        // Perform group_by_dynamic for resampling
        let result_lf = lf
            .group_by_dynamic(
                col(time_col),
                [],
                DynamicGroupOptions {
                    every: duration,
                    period: duration,
                    offset: Duration::parse("0s"),
                    label: Label::Left,
                    include_boundaries: false,
                    closed_window: ClosedWindow::Left,
                    start_by: StartBy::DataPoint,
                    check_sorted: true,
                },
            )
            .agg(agg_exprs);

        // Collect the result
        let result_df = result_lf.collect()?;

        // Create new TimeSeriesData with resampled data
        TimeSeriesData::new(result_df, Some(time_col))
    }

    fn name(&self) -> &str {
        "resample"
    }
}
