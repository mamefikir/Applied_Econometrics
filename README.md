# Advanced Applied Econometrics
- Overview_of_Stata
- STATA_Applied_Econometrics
- STATA_Code_Samples
- Additional_Topics_Applied_Econometrics (SPSS & R)
<br/>


## `STATA Data Processing`

**Useful Shortcuts** | (STATA)
-------------------- | --------------------
**`Ctrl + 8`**: open the data editor | **`clear`**: delete data in memory
**`F2(keyboard buttons)`**: describe data | **`Ctrl + 9`**: open a new .do file 
**`PgUp`**: scroll through previous commands | **`PgDn`**: scroll through previous commands
**`Tab`**: autocompletes variable name after typing part | **`cls`**: clear the console 

### STATA - Set up
- **`pwd`**: print current (working) directory
- **`cd`**: change working directory
- **`dir`**: display filenames in working directory
- **`fs *.dta`**: List all Stata data in working directory
- **`capture log close`**: close the log on any existing do files
- **`log using "myDoFile.txt", replace`**: create a new log file to record your work and results
- **`search mdesc`**: find the package mdesc to install
- **`ssc install mdesc`**: install the package mdesc; needs to be done once

### STATA - Import Data
- **`sysuse auto, clear`**: load system data (Auto data)
- **`use "yourStataFile.dta", clear`**: load a dataset from the current directory

### STATA - Basic Syntax
![alt text](https://github.com/David-SF2290/Advanced_Applied_Econometrics/blob/master/Graph_Doc/Basic%20Syntax.JPG)

### STATA Basic Data Operations
![alt text](https://github.com/David-SF2290/Advanced_Applied_Econometrics/blob/master/Graph_Doc/Basic%20Data%20Operations.JPG)

### STATA - Explore Data

**VIEW DATA ORGANIZATION** | (STATA)
-------------------------- | --------------------------
**`describe`**: display variable type, format, and any value/variable labels | **`count`**: number of rows (observations) Can be combined with logic
**`lookfor "in."`**: search for variable types, variable name, or variable label | **`isid`**: check if mpg uniquely identifies the data


**SEE DATA DISTRIBUTION**  | (STATA)
-------------------------- | --------------------------
**`codebook`**: overview of variable type, stats, number of missing/unique values | **`summarize`**: print summary statistics (mean, stdev, min, max) for variables
**`inspect`**: show histogram of data, number of missing or zero observations | **`histogram`**: plot a histogram of the distribution of a variable

### STATA - Import Data
- **`browse`**: open the data editor
- **`list make price if price > 10000 & !missing(price)`**: list the make and price for observations with price > $10,000
- **`display price[4]`**: display the 4th observation in price; only works on single values
- **`gsort price mpg & gsort–price–mpg`**: sort in order, first by price then miles per gallon
- **`duplicates report`**: finds all duplicate values in each variable
- **`assert price!=.`**: verify truth of claim
- **`levelsof rep78`**: display the unique values for rep78

### STATA - Create New Variables
- **`generate mpgSq = mpg^2 `**: create a new variable
- **`generate id = _n`**: _n creates a running index of observations in a group
- **`generate totRows = _N`**: _N creates a running count of the total observations per group



## `STATA Data Visualization`

### STATA - One Variable (Continuous & Discrete)
![alt text](https://github.com/David-SF2290/Advanced_Applied_Econometrics/blob/master/Graph_Doc/One%20Variable.jpg)

### STATA - Two Variables (Continuous)
![alt text](https://github.com/David-SF2290/Advanced_Applied_Econometrics/blob/master/Graph_Doc/TWO%20CONTINUOUS%20VARIABLES.JPG)

### STATA - Three Variables 
![alt text](https://github.com/David-SF2290/Advanced_Applied_Econometrics/blob/master/Graph_Doc/3.JPG)

### STATA - Customizing Appearance
![alt text](https://github.com/David-SF2290/Advanced_Applied_Econometrics/blob/master/Graph_Doc/Plot1.JPG)

![alt text](https://github.com/David-SF2290/Advanced_Applied_Econometrics/blob/master/Graph_Doc/Plot2.JPG)



## `STATA Data Transformation`

### STATA - Manipulate Strings
- **`display length`**: return the length of the string
- **`charlist`**: display the set of unique characters within a string
- **`display strpos("Stata", "a")`**: return the position in Stata where a is first found
- **`display strmatch("123.89", "1??.?9")`**: return true (1) or false (0) if string matches pattern
- **`display stritrim(" Too much Space")`**: replace consecutive spaces with a single space
- **`display trim(" leading / trailing spaces ")`**: remove extra spaces before and after a string
- **`display real("100")`**: convert string to a numeric or missing value



## `STATA Programming`

### STATA - Loops: Automate Repetitive Tasks
Stata has three options for repeating commands over lists or values: foreach, forvalues, and while. Though each has a different first line, the syntax is consistent:

![alt text](https://github.com/David-SF2290/Advanced_Applied_Econometrics/blob/master/Graph_Doc/Loop.JPG)

### STATA - Debugging Code
- **`set trace on (off)`**: trace the execution of programs for error checking

## `STATA - Data Analysis`

### STATA - Estimate Models

- **`regress`**: estimate ordinary least squares (OLS) model
- **`rreg`**: estimate robust regression to eliminate outliers
- **`probit`**: estimate probit regression 
- **`logit`**: estimate logistic regression

### STATA - Estimation with Categorical & Factor Variables
![alt text](https://github.com/David-SF2290/Advanced_Applied_Econometrics/blob/master/Graph_Doc/Estimation%20with%20Categorical.JPG)


### STATA - Declare Data

![alt text](https://github.com/David-SF2290/Advanced_Applied_Econometrics/blob/master/Graph_Doc/Data.JPG)


## `STATA_Applied_Econometrics`

- Introducing Stata 
- Simple Linear Regression 
- Interval Estimation and Hypothesis Testing 
- Prediction, Goodness of Fit and Modeling Issues 
- Multiple Linear Regression 
- Further Inference in the Multiple Regression Model 
- Using Indicator Variables 
- Heteroskedasticity 
- Regression with Time-Series Data: Stationary Variables 
- Random Regressors and Moment Based Estimation 
- Simultaneous Equations Models 
- Regression with Time-Series Data: Nonstationary Variables 
- Vector Error Correction and Vector Autoregressive Models 
- Time-Varying Volatility and ARCH Models 
- Panel Data Models 
- Qualitative and Limited Dependent Variable Models

## `STATA_Code_Samples`

- Count_Data_Models.do
- Durbin_Watson_Test.do
- Error_Correlation_Model.do
- Factor_Analysis.do
- Further_Inference_in_the_Multiple_Regression_Model.do
- Graphing_Time_Series_Data.do
- Heteroskedasticity.do
- Instrumental_Variables_Estimation.do
- Introducing_Stata.do
- Limited_Dependent_Variable.do
- Logistic_Regression.do
- Panel_Data.do
- Principal_Component_Analysis.do
- Propensity_Score_Matching.do
- Quantile_Regression.do
- Regression_with_Time-Series_Data-Nonstationary_Variables.do
- Seemingly_Unrelated_Regressions.do
- Simple_Linear_Regression.do
- Spatial_Econometrics.do
- Survival_Analysis.do
- The_Multiple_Regression_Model.do
- Time_Series_ARIMA.do

## `Additional_Topics_Applied_Econometrics (SPSS & R)`

- `R_Applied_Econometrics`
  - Probit and Logit Models

- `SPSS_Applied_Econometrics`
  - Introducing SPSS
  - Linear Regression Model 
  
- `STATA_Applied_Econometrics`
  - Mathematical Tools
  - Probability Concepts
  - Statistical Inference

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
