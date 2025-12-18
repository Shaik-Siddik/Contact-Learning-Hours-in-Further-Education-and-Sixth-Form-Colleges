/* Importing the CSV files for Sixth Form Colleges and Further Education Colleges */
proc import datafile='/home/u64158649/sasuser.v94/CSIP5302-6form.csv'
    out=sixth_form_data
    dbms=csv
    replace;
    getnames=yes;
run;

proc import datafile='/home/u64158649/sasuser.v94/CSIP5302-FE.csv'
    out=fe_data
    dbms=csv
    replace;
    getnames=yes;
run;

/* Importing the .tab file for Further Education metrics */
proc import datafile='/home/u64158649/sasuser.v94/CSIP5302-FEmetric02.tab'
    out=fe_metrics
    dbms=tab
    replace;
    getnames=yes;
run;

/* View the first few records to check for anomalies */
proc print data=sixth_form_data (obs=10);
run;

proc print data=fe_data (obs=10);
run;

proc print data=fe_metrics (obs=10);
run;

/* Checking summary statistics to identify any obvious anomalies (e.g., missing data, outliers) */
proc means data=sixth_form_data n mean std min max;
run;

proc means data=fe_data n mean std min max;
run;

proc means data=fe_metrics n mean std min max;
run;

/*Calculating CH per Learner*/

/* Calculate CH per learner for Sixth Form Colleges */
data sixth_form_data;
    set sixth_form_data;
    CH_per_learner_Year2 = "Total CH Year 2"n / Learners2;
    CH_per_learner_Year3 = "Total CH Year 3"n  / "Learners 3"n;
run;

/* Calculate CH per learner for Further Education Colleges */
data fe_data;
    set fe_data;
    CH_per_learner_Year1 = "Total CH Year 1"n / Learners;
    CH_per_learner_Year2 = "Total CH Year 2"n / Learners;
    CH_per_learner_Year3 = "Total CH Year 3"n  / Learners;
run;

/* EDA: Histograms for Contact Learning Hours (CH) */
proc sgplot data=sixth_form_data;
    histogram CH_per_learner_Year2 / transparency=0.5;
    title 'Distribution of Contact Learning Hours (Year 2) - Sixth Form Colleges';
run;

proc sgplot data=fe_data;
    histogram CH_per_learner_Year3 / transparency=0.5;
    title 'Distribution of Contact Learning Hours (Year 3) - FE Colleges';
run;

/* EDA: Scatter plots for Gender Ratio vs. CH per Learner */
proc sgplot data=sixth_form_data;
    scatter x=CH_per_learner_Year3 y=GPercentFemale;
    title 'Scatter Plot of Female Percentage vs. Contact Learning Hours per Learner - Sixth Form Colleges';
run;

proc sgplot data=fe_data;
    scatter x=CH_per_learner_Year2 y=GPercentMale;
    title 'Scatter Plot of Male Percentage vs. Contact Learning Hours per Learner - FE Colleges';
run;

/* Generating a summary table of meta data */
proc contents data=sixth_form_data;
run;

proc contents data=fe_data;
run;

proc contents data=fe_metrics;
run;

/* Checking for missing values and anomalies in CH per learner */
proc freq data=sixth_form_data;
    tables CH_per_learner_Year2 CH_per_learner_Year3 / missing;
run;

proc freq data=fe_data;
    tables CH_per_learner_Year1 CH_per_learner_Year2 CH_per_learner_Year3 / missing;
run;
/*Defining Institution Size Based on CH per Learner*/

data sixth_form_data;
    set sixth_form_data;

    if CH_per_learner_Year2 > 150 then size_Year2 = 'Large';
    else if 100 <= CH_per_learner_Year2 < 150 then size_Year2 = 'Large-medium';
    else if 75 <= CH_per_learner_Year2 < 100 then size_Year2 = 'Medium';
    else if 50 <= CH_per_learner_Year2 < 75 then size_Year2 = 'Small-medium';
    else size_Year2 = 'Small';

    if CH_per_learner_Year3 > 150 then size_Year3 = 'Large';
    else if 100 <= CH_per_learner_Year3 < 150 then size_Year3 = 'Large-medium';
    else if 75 <= CH_per_learner_Year3 < 100 then size_Year3 = 'Medium';
    else if 50 <= CH_per_learner_Year3 < 75 then size_Year3 = 'Small-medium';
    else size_Year3 = 'Small';
run;

data fe_data;
    set fe_data;
    if CH_per_learner_Year1 > 150 then size_Year1 = 'Large';
    else if 100 <= CH_per_learner_Year1 < 150 then size_Year1 = 'Large-medium';
    else if 75 <= CH_per_learner_Year1 < 100 then size_Year1 = 'Medium';
    else if 50 <= CH_per_learner_Year1 < 75 then size_Year1 = 'Small-medium';
    else size_Year1 = 'Small';

    if CH_per_learner_Year2 > 150 then size_Year2 = 'Large';
    else if 100 <= CH_per_learner_Year2 < 150 then size_Year2 = 'Large-medium';
    else if 75 <= CH_per_learner_Year2 < 100 then size_Year2 = 'Medium';
    else if 50 <= CH_per_learner_Year2 < 75 then size_Year2 = 'Small-medium';
    else size_Year2 = 'Small';

    if CH_per_learner_Year3 > 150 then size_Year3 = 'Large';
    else if 100 <= CH_per_learner_Year3 < 150 then size_Year3 = 'Large-medium';
    else if 75 <= CH_per_learner_Year3 < 100 then size_Year3 = 'Medium';
    else if 50 <= CH_per_learner_Year3 < 75 then size_Year3 = 'Small-medium';
    else size_Year3 = 'Small';
run;

/* Multivariate Analysis of Variance (MANOVA) */
proc glm data=sixth_form_data;
    class VAR10 Learners2 size_year2 "Total CH Year 2"n;
    model CH_per_learner_year2 VAF GradPR = VAR10 Learners2 size_year2 "Total CH Year 2"n;
run;

proc glm data=fe_data;
    class VAR9 Learners size_year3 "Total CH Year 3"n;
    model CH_per_learner_year3 GPercentMale= VAR9 Learners size_year3 "Total CH Year 3"n;
run;

/* Logistic Regression for Graduation Pass Rate (binary outcome) */
data sixth_form_data;
    set sixth_form_data;
    if GradPR >= 0.75 then success = 1;
    else success = 0;
run;

proc logistic data=sixth_form_data;
    class VAR10 Learners2 size_year2 "Total CH Year 2"n;
    model success = VAR10 Learners2 size_year2;
run;

/* K-Means Clustering */
proc fastclus data=fe_data maxclusters=4 out=cluster_output;
    var CH_per_learner_year2 GPercentMale;
run;

