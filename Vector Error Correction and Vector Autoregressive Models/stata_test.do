use stata_test_2019, clear
// Dropbox link: https://www.dropbox.com/s/mrxk0memgzwa4b3/stata_test_2019.dta?dl=0

/****************/
/* INSTRUCTIONS */
/****************/

/*

You have three hours to complete this test. We will be looking at your
code, your numeric answers, as well as your explanations of those
answers. Code should be efficient and clear; use self-explanatory
variable names and comments.

Please put your answers in a separate document. Include whatever
graphs and/or regression tables are necessary to prove your arguments.
Please include observation counts in any regression analyses.

Please write your code in such a way that it is clear to us which part of
your code refers to which answer. We suggest you can write your code
directly inline in this do file.

Villages are uniquely identified by the variables pc01_state_id
pc01_village_id.  Districts are uniquely identified by the variables
pc01_state_id pc01_district_id.  Names of the above are in
pc01_state_name, pc01_district_name, pc01_village_name.

Prefixes have the following meanings:
pc01 = 2001 Indian Population Census
ec98 = 1998 Economic Census
ec05 = 2005 Economic Census
emp  = employment
vd   = village directory (village amenities/public goods table)
pca  = population census abstract (demographic data)

You can find more information about the fields online, but I don't
recommend you do so, because it takes a lot of time to get the right
information. If you need help understanding the coding of a variable, 
you can text us, or just make an assumption about what it means and 
tell us what you assumed.


This is a village-level dataset, i.e. one observation for every
village in India. This is raw data directly from the economic census and
road-building administrative data, and has been minimally cleaned.

TIP 1: Think about your answers once you get them! Do they make sense?
Think of ways to check the validity of your answers in the data.

TIP 2: If you don't know how to do a question, skip it and come back
to it. Don't spend 90 minutes on one question.

TIP 3: For Part 2, you won't find the answers in our papers -- this is 
an invented example with invented data just for this test.

*/

/*********************/
/* PART 1: 1.5 HOURS */
/*********************/

/* 1.
(a)
The variables ec90_emp_all, ec98_emp_all and ec05_emp_all show total
village-level non-farm employment. We often like to study log
employment rather than level employment.  Create logs of these
variables. Why do we use logs instead of levels? Are there any
disadvantages?  Report the village average of log employment in 2005.

*/


/* 1.
(b)
How many villages have more than 200 people working in non-farm
jobs in 2005? */


/*
2.

The variable ec05_emp_NICX contains the number of workers in industry
category X. NIC codes 7 through 16 represent the following mining
industries:

      7   Mining and agglomeration of hard coal
      8   Mining and agglomeration of lignite
      9   Extraction and agglomeration of peat
     10   Extraction of crude petroleum and natural gas
     11   Service activities incidental to oil and gas extraction excluding surveying
     12   Mining of uranium and thorium ores (e.g. pitchblende), including concentrating
     13   Mining of iron ores
     14   Mining of non-ferrous metal ores, except uranium and thorium ores
     15   Quarrying of stone, sand and clay
     16   Mining of chemical and fertilizer minerals

Create a variable that contains the total village level employment in
all of these industries combined. Report the average number of mining
jobs per village in 1998 and 2005.
*/



/*
3.
There are approximately 500 districts in India.  Remember
pc01_district_id uniquely identifies a district only within
pc01_state_id. Calculate the mean and median district-level
employment in 1998 and 2005. */

/*
4.
Are there any duplicate observations in our dataset?
(pc01_state_id pc01_village_id are supposed to uniquely identify a
village).  If so, report the number of duplicates, and drop them (Keep
one out of each set). (Note that a duplicate is any two observations
with the same pc01_state_id and pc01_village_id, even if the number of
reported jobs is different)
*/


/* 5.  The variables comp_year, comp_month and comp_day describe the
year, month and day in which a new road was built to a village. (They
are missing if a village did not get a new road). Create a variable
that contains the number of days since a new road was built, as of
January 1, 2006. Call it days_with_road. This variable should be
missing if a road has not been built in the village by this
date. Print the result of the command "sum days_with_road." */


/* 6. Create a variable “outlier” that takes the value 1 if the 2005
number of nonfarm jobs is *outside* the 1st/99th percentiles. If
possible, write the code in such a way that if we run it on the subset
of the data (or a different variable), it will still cut at the 1st /
99th percentile in the subset of the data. (i.e. don't hardcode the
number of jobs currently at the 99th percentile.) How many outlier
villages did you drop? */



/***************************************/
/* Part 2: 1.5 hours                   */
/* Research Design -- Impacts of roads */
/***************************************/

/*
1.
The variable pc01_vd_app_pr is a dummy variable that takes the
value 1 if a village has a road in 2001. Using the number of nonfarm
jobs per person in 2005 as a proxy for village economic
development, describe the cross-sectional relationship between this
variable and local development. (To calculate jobs per capita, use
population in 2001, which is in the variable pc01_pca_tot_p.) First
describe the bivariate relationship, then control for village
characteristics that might be important. 

If we are interested in the causal impact of roads on development,
should you control for other variables, like village population, land
area, or the number of schools or hospitals?  Why should or shouldn't
you do this? Control for whatever you think is appropriate.  */




/*
2.
Is this a good estimate of the causal impact of roads on local
development?  Why or why not? */



/*
For Questions #3 and #4:

Between 2001 and 2003, a subset of districts were randomly assigned to
be treated with roads. There were 254 districts in the experiment. 128
were assigned to be treated, and 126 were kept as controls.

The government did not have enough money to connect all villages in
treated districts. But nearly all road funding went to treated
districts.  Roads were not randomly assigned within districts -- they
may have been targeted to faster or slower growing villages, or to
richer or poorer villages. We don't really know. But you can assume
that the targeting rule (whatever it is) is the same in all districts.

The variable "experiment_treatment" is 1 for treatment villages. The
variable "experiment_control" is set to 1 for control villages.  It's
up to you whether you want to include other districts in the
analysis.  The variable "village_new_road" takes the value 1 if a
village received a new road. (Not every village in a treated district
received a new road).

Please ignore the variables comp_year, comp_month and comp_day for
this question -- they don't correspond to the experiment in question.

3.
Are the treatment and control groups balanced on village
population?
*/


/* 4.  Estimate the impact of roads on development, again using 2005
jobs per person as a proxy for development. Make your own judgments on
whether to include control variables, how to handle outliers,
clustering, missing or duplicate observations, etc., but be sure to
document and explain all the choices that you made. Explain the
results you find and discuss what further analysis you would do if you
had additional data.

Does this setup allow you to say anything about the causal impacts of
roads? Write up your results and empirical strategy here as if you
were writing a paper -- explain why the choices that you make are
the right ones.

If you are unsure about certain things, or if you think the results
are ambiguous, it is ok to say so. We are interested in seeing how you
think about this problem.

*/


/* GOOD LUCK!! */
  
