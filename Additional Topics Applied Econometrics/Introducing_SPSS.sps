* Introduction to SPSS.
* David Li 

* Read SPSS data file.
GET
  FILE='C:\Econometrics\Data\intro_auto.sav'.
DATASET NAME DataSet1 WINDOW=FRONT.

* Read Excel file.
GET DATA /TYPE=XLSX
  /FILE='C:\Econometrics\Data\intro_auto.xlsx'
  /SHEET=name 'Sheet1'
  /CELLRANGE=full
  /READNAMES=on
  /ASSUMEDSTRWIDTH=32767.
EXECUTE.
DATASET NAME DataSet2 WINDOW=FRONT.

* Read csv file.
GET DATA  /TYPE=TXT
  /FILE="C:\Econometrics\Data\intro_auto.csv"
  /ENCODING='Locale'
  /DELCASE=LINE
  /DELIMITERS=","
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /IMPORTCASE=ALL
  /VARIABLES=
  make A9
  price F5.0
  mpg F2.0
  repairs F1.0
  weight F4.0
  length F3.0
  foreign F1.0.
CACHE.
EXECUTE.
DATASET NAME DataSet3 WINDOW=FRONT.

* Activating data set.
DATASET ACTIVATE DataSet1.

* Descriptive statistics
* Analyze>Descriptive Statistics>Descriptives.
DESCRIPTIVES VARIABLES=price mpg repairs weight length foreign
  /STATISTICS=MEAN STDDEV MIN MAX.

* Frequency tables.
* Analyze>Descriptive Statistics>Frequencies.
FREQUENCIES VARIABLES=make foreign
  /ORDER=ANALYSIS.

* Correlations among variables.
* Analyze>Correlate>Bivariate.
CORRELATIONS
  /VARIABLES=price mpg
  /PRINT=TWOTAIL NOSIG
  /MISSING=PAIRWISE.

* T-test for mean of one group.
* Analyze>Compare Means>One Sample T-test.
T-TEST
  /TESTVAL=20
  /MISSING=ANALYSIS
  /VARIABLES=mpg
  /CRITERIA=CI(.95).

* ANOVA for equality of means for two groups.
* Analyze>Compare means>One way ANOVA.
ONEWAY mpg BY foreign
  /MISSING ANALYSIS.

* OLS regression. 
* Analyze>Regression>Linear.
REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT mpg
  /METHOD=ENTER price weight length.

* Chart Builder.
* Graphs>Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=weight mpg MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: weight=col(source(s), name("weight"))
  DATA: mpg=col(source(s), name("mpg"))
  GUIDE: axis(dim(1), label("weight"))
  GUIDE: axis(dim(2), label("mpg"))
  ELEMENT: point(position(weight*mpg))
END GPL.
