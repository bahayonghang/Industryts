# Spec Delta: Time Series Processing Operations

## ADDED Requirements

### Requirement: Data Cleaning - Missing Value Handling
The system SHALL provide multiple methods for handling missing values in time series data.

#### Scenario: Forward fill
- **WHEN** user applies forward fill to columns with null values
- **THEN** each null value SHALL be replaced with the most recent non-null value in that column

#### Scenario: Backward fill
- **WHEN** user applies backward fill to columns with null values
- **THEN** each null value SHALL be replaced with the next non-null value in that column

#### Scenario: Linear interpolation
- **WHEN** user applies linear interpolation to columns with null values
- **THEN** null values SHALL be replaced with linearly interpolated values based on surrounding non-null values

#### Scenario: Drop nulls
- **WHEN** user drops rows with null values
- **THEN** all rows containing any null values in specified columns SHALL be removed

### Requirement: Data Cleaning - Outlier Detection
The system SHALL provide statistical methods for detecting outliers in time series data.

#### Scenario: IQR method detection
- **WHEN** user applies IQR outlier detection with factor 1.5
- **THEN** values outside [Q1 - 1.5*IQR, Q3 + 1.5*IQR] SHALL be marked as outliers

#### Scenario: Z-score method detection
- **WHEN** user applies Z-score outlier detection with threshold 3.0
- **THEN** values with |Z-score| > 3.0 SHALL be marked as outliers

### Requirement: Data Cleaning - Outlier Handling
The system SHALL provide methods to handle detected outliers.

#### Scenario: Outlier capping
- **WHEN** user applies capping to outliers
- **THEN** outlier values SHALL be replaced with the boundary values (upper or lower threshold)

#### Scenario: Outlier removal
- **WHEN** user removes outliers
- **THEN** rows containing outlier values SHALL be removed from the dataset

### Requirement: Data Cleaning - Duplicate Removal
The system SHALL identify and remove duplicate rows based on time column.

#### Scenario: Remove exact duplicates
- **WHEN** multiple rows have identical time values
- **THEN** only the first occurrence SHALL be kept

#### Scenario: Remove duplicates with aggregation
- **WHEN** multiple rows have identical time values and user specifies aggregation method
- **THEN** duplicates SHALL be aggregated using the specified method (mean, sum, first, last)

### Requirement: Time Operations - Resampling
The system SHALL support upsampling and downsampling of time series data.

#### Scenario: Downsample with aggregation
- **WHEN** user resamples from 1-minute to 1-hour intervals with mean aggregation
- **THEN** data SHALL be grouped into 1-hour bins and aggregated using mean

#### Scenario: Upsample with forward fill
- **WHEN** user upsamples from 1-hour to 1-minute intervals
- **THEN** missing values SHALL be created and filled using forward fill

#### Scenario: Multiple aggregation methods
- **WHEN** user specifies different aggregation methods for different columns
- **THEN** each column SHALL be aggregated using its specified method

### Requirement: Time Operations - Rolling Window
The system SHALL compute rolling window statistics over time series data.

#### Scenario: Rolling mean
- **WHEN** user applies rolling mean with window size 10
- **THEN** each value SHALL be the mean of the current and 9 previous values

#### Scenario: Rolling standard deviation
- **WHEN** user applies rolling std with window size 20
- **THEN** each value SHALL be the standard deviation of the current and 19 previous values

#### Scenario: Custom window statistics
- **WHEN** user applies rolling operation with custom function (min, max, sum, median)
- **THEN** the custom function SHALL be applied to each window

### Requirement: Time Operations - Time Alignment
The system SHALL align multiple time series to a common time index.

#### Scenario: Inner join alignment
- **WHEN** aligning two time series with inner join
- **THEN** only timestamps present in both series SHALL be retained

#### Scenario: Outer join alignment
- **WHEN** aligning two time series with outer join
- **THEN** all timestamps from both series SHALL be retained with nulls for missing values

### Requirement: Time Operations - Time-based Filtering
The system SHALL filter time series data based on time ranges and patterns.

#### Scenario: Date range filtering
- **WHEN** user filters data between two dates
- **THEN** only rows with timestamps within the range (inclusive) SHALL be returned

#### Scenario: Time of day filtering
- **WHEN** user filters for specific hours (e.g., 9 AM to 5 PM)
- **THEN** only rows with timestamps in that time range SHALL be returned

#### Scenario: Weekday filtering
- **WHEN** user filters for weekdays only
- **THEN** only rows with timestamps on Monday-Friday SHALL be returned

### Requirement: Feature Engineering - Lag Features
The system SHALL create lagged versions of feature columns.

#### Scenario: Single lag
- **WHEN** user creates lag-1 feature for column "value"
- **THEN** a new column "value_lag_1" SHALL contain values shifted by 1 time step

#### Scenario: Multiple lags
- **WHEN** user creates lags [1, 2, 3] for column "value"
- **THEN** three new columns "value_lag_1", "value_lag_2", "value_lag_3" SHALL be created

### Requirement: Feature Engineering - Date/Time Features
The system SHALL extract date and time components as features.

#### Scenario: Extract hour
- **WHEN** user extracts hour from time column
- **THEN** a new column "hour" SHALL contain integer hour values (0-23)

#### Scenario: Extract multiple components
- **WHEN** user extracts [year, month, day, hour, weekday]
- **THEN** five new columns SHALL be created with respective temporal components

### Requirement: Feature Engineering - Differencing
The system SHALL compute differences between consecutive values.

#### Scenario: First-order differencing
- **WHEN** user applies first-order differencing to column "value"
- **THEN** a new column SHALL contain value[t] - value[t-1]

#### Scenario: Seasonal differencing
- **WHEN** user applies seasonal differencing with period 24
- **THEN** a new column SHALL contain value[t] - value[t-24]

### Requirement: Feature Engineering - Window Statistics
The system SHALL compute statistics over rolling windows as features.

#### Scenario: Moving average features
- **WHEN** user creates moving average with windows [5, 10, 20]
- **THEN** three new columns SHALL contain the respective window averages

#### Scenario: Moving std features
- **WHEN** user creates moving std with window 10
- **THEN** a new column SHALL contain rolling standard deviation

### Requirement: Feature Engineering - Cyclical Encoding
The system SHALL encode cyclical time features using sine and cosine transformations.

#### Scenario: Hour encoding
- **WHEN** user encodes hour (0-23) cyclically
- **THEN** two columns "hour_sin" and "hour_cos" SHALL be created with sin/cos transformations

#### Scenario: Month encoding
- **WHEN** user encodes month (1-12) cyclically
- **THEN** two columns "month_sin" and "month_cos" SHALL be created

### Requirement: Aggregation - Group By Time Bins
The system SHALL aggregate data by time bins (hourly, daily, weekly, monthly).

#### Scenario: Daily aggregation
- **WHEN** user groups by day with mean aggregation
- **THEN** data SHALL be aggregated to one row per day with mean values

#### Scenario: Custom time bins
- **WHEN** user groups by custom interval (e.g., 15 minutes)
- **THEN** data SHALL be aggregated to the specified interval

### Requirement: Aggregation - Cumulative Operations
The system SHALL compute cumulative statistics over time.

#### Scenario: Cumulative sum
- **WHEN** user applies cumulative sum to column "value"
- **THEN** each row SHALL contain the sum of all previous values including current

#### Scenario: Cumulative max
- **WHEN** user applies cumulative max to column "value"
- **THEN** each row SHALL contain the maximum value seen up to that point

### Requirement: Aggregation - Expanding Window
The system SHALL compute statistics over expanding windows.

#### Scenario: Expanding mean
- **WHEN** user applies expanding mean
- **THEN** row i SHALL contain the mean of rows 0 to i

### Requirement: Transformations - Standardization
The system SHALL standardize features using z-score normalization.

#### Scenario: Z-score normalization
- **WHEN** user standardizes column "value"
- **THEN** the column SHALL be transformed to have mean 0 and std 1

#### Scenario: Per-group standardization
- **WHEN** user standardizes within time groups
- **THEN** each group SHALL be independently standardized

### Requirement: Transformations - Min-Max Scaling
The system SHALL scale features to a specified range.

#### Scenario: Scale to [0, 1]
- **WHEN** user applies min-max scaling to column "value"
- **THEN** values SHALL be scaled to range [0, 1]

#### Scenario: Custom range scaling
- **WHEN** user specifies range [-1, 1]
- **THEN** values SHALL be scaled to range [-1, 1]

### Requirement: Transformations - Log Transform
The system SHALL apply logarithmic transformations to features.

#### Scenario: Natural log
- **WHEN** user applies log transform to column "value"
- **THEN** values SHALL be transformed using natural logarithm (ln)

#### Scenario: Log with offset
- **WHEN** user applies log(x + 1) transform
- **THEN** values SHALL be transformed using log(x + 1) to handle zeros

### Requirement: Transformations - Box-Cox Transform
The system SHALL apply Box-Cox power transformation to stabilize variance.

#### Scenario: Automatic lambda selection
- **WHEN** user applies Box-Cox without specifying lambda
- **THEN** optimal lambda SHALL be automatically determined using maximum likelihood

#### Scenario: Manual lambda
- **WHEN** user specifies lambda parameter
- **THEN** Box-Cox transformation SHALL use the specified lambda

### Requirement: Transformations - Robust Scaling
The system SHALL scale features using median and IQR (robust to outliers).

#### Scenario: Robust scaling
- **WHEN** user applies robust scaling to column "value"
- **THEN** values SHALL be transformed to (x - median) / IQR

### Requirement: Performance Optimization
All operations SHALL leverage Polars' optimized execution engine for high performance.

#### Scenario: Lazy evaluation
- **WHEN** user chains multiple operations
- **THEN** operations SHALL be optimized and executed together when possible

#### Scenario: Parallel execution
- **WHEN** operations can be parallelized
- **THEN** Polars SHALL automatically use available CPU cores

### Requirement: Column Selection
All operations SHALL support column selection via names, patterns, or data types.

#### Scenario: Specific columns
- **WHEN** user specifies columns=["col1", "col2"]
- **THEN** only those columns SHALL be processed

#### Scenario: All numeric columns
- **WHEN** user specifies columns="numeric"
- **THEN** all numeric feature columns SHALL be processed

#### Scenario: Pattern matching
- **WHEN** user specifies pattern "temp_*"
- **THEN** all columns starting with "temp_" SHALL be processed
