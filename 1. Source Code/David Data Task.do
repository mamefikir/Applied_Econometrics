* David Li
* 18/Feb/20

* Q1 Importing Raw Data
import delimited "/home/mivazq/Desktop/data_ecuador.csv", clear 

* ETL
replace reported_revenue =. if reported_revenue  == 9999999
replace reported_costs =. if reported_costs == 9999999
replace firmsize ="." if firmsize == "9999999"

replace reported_revenue =. if reported_revenue  <= 0
replace reported_costs =. if reported_costs <=0

* Summary Statistics 
summarize reported_revenue reported_costs

* Q2 Encoding 
encode region, generate(region_n)
proportion region_n if email ==1

* We can use the stationary process to verify whether the randomization over coastal and non-coastal firms was successful applying variance and standard deviation. Based on the proportion estimation, it is good randomization.
 
* Q3 (a) According to figure 1, Companies who received emails reported more revenues compares to the companies that don’t receive the email. There is a more substantial difference if companies have a bigger size.

* Q3 (b) We can use the following steps: 
(1) Summarizing variables
(2) Comparing the independent association of each variable to the outcome and doing bivariate analysis
(3)  Using logistic regression to find if emails have a greater effect on larger firms. *

* Q4 (a)
tab email
bysort email: sum reported_revenue
ttest reported_revenue, by(email)
gen lnreported_revenue = ln(reported_revenue)
ttest lnreported_revenue, by(email)
reg lnreported_revenue email, cluster(firmsize)
 
* Q4 (b)
bysort email: sum reported_costs
ttest reported_costs, by(email)
gen lnreported_costs = ln(reported_costs)
ttest lnreported_costs, by(email)
reg lnreported_costs email, cluster(firmsize)
 
* Q4 (c)
generate tax_lia = reported_revenue - reported_costs
bysort email: sum tax_lia
ttest tax_lia, by(email)
gen lntax_lia = ln(tax_lia)
ttest llntax_lia, by(email)
reg lnreported_costs email, cluster(firmsize)
 
* Q5
According to the statistical results, we can include more independent variables in the model to improve stability and reliability. The model will also have more capcity to study the effect of an intervention a new technology that can check the accuracy of the revenue they report on the annual tax forms.

* Q6
gen rrlf = sum(reported_revenue) if firmsize == "<5 employees"
gen rrlt = sum(reported_revenue) if firmsize == "5 to 10"
gen rrlft = sum(reported_revenue) if firmsize == "10 to 50"
gen rrlo = sum(reported_revenue) if firmsize == "50 to 100"
gen rrmo = sum(reported_revenue) if firmsize == "100+"

Marginsplot, title(Figure 1: Reported by the Treatment/Control group) ///
                 ytitle(Reported Revenue) /// 
        legend(ring(), bplacement() cols())
