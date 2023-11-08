libname myhome '/home/u59906376/';

data myhome.BMILDA;
    set myhome.BMILDA; 
    AGE = FAGE + TIME; 
run;


proc means data=myhome.BMILDA n mean min max std;
   var TIME BMI FAGE;
run;

proc freq data=myhome.BMILDA;
   tables SEX SMOKING;
run;

/* Boxplot for BMI across SEX and SMOKING */
proc sgplot data=myhome.BMILDA;
   vbox BMI / category=SEX;
   run;/* Boxplot for BMI across SEX and SMOKING */
proc sgplot data=myhome.BMILDA;
   vbox BMI / category=SEX;
   run;

proc sgplot data=myhome.BMILDA;
   vbox BMI / category=SMOKING;
   run;

/* Time-series plot for BMI */
proc sgplot data=myhome.BMILDA;
   series x=TIME y=BMI;
   run;


proc sgplot data=myhome.BMILDA;
   vbox BMI / category=SMOKING;
   run;

/* Time-series plot for BMI */
proc sgplot data=myhome.BMILDA;
   series x=TIME y=BMI;
   run;
   
/* Histogram for BMI */
proc sgplot data=myhome.BMILDA;
   histogram BMI;
   density BMI;
   run;

/* Scatter plot for BMI vs. FAGE */
proc sgplot data=myhome.BMILDA;
   scatter x=AGE y=BMI;
   run;

/* Correlation matrix for numerical variables */
proc corr data=myhome.BMILDA;
   var TIME BMI AGE;
run;

proc sql;
  select count(distinct ID) into :uniqueIDs
  from myhome.BMILDA;
quit;


/* Calculate the mean BMI for each age group */
proc sql;
    create table mean_bmi as
    select AGE, mean(BMI) as Mean_BMI
    from myhome.BMILDA
    group by AGE
    order by AGE; /* Make sure the results are sorted by AGE */
quit;

/* Plot the mean BMI by AGE */
proc sgplot data=mean_bmi;
    scatter x=AGE y=Mean_BMI / markerattrs=(symbol=circlefilled);
    xaxis label='Age';
    yaxis label='Mean BMI';
    title 'Mean BMI by Age';
run;

/* Calculate the mean BMI for each age group by smoking status */
proc sql;
    create table mean_bmi_by_smoking as
    select AGE, SMOKING, mean(BMI) as Mean_BMI
    from myhome.BMILDA
    group by AGE, SMOKING
    order by AGE, SMOKING; /* Make sure the results are sorted by AGE and SMOKING */
quit;


/* Plot the mean BMI by AGE for smokers and non-smokers with different colors */
proc sgplot data=mean_bmi_by_smoking;
    series x=AGE y=Mean_BMI / group=SMOKING markers lineattrs=(thickness=2) 
        markerattrs=(symbol=circlefilled) 
        groupdisplay=cluster; /* Adjusts how the group values are displayed */
    xaxis label='Age';
    yaxis label='Mean BMI';
    title 'Mean BMI by Age and Smoking Status';
run;

/* Calculate the variance of BMI for each age group */
proc means data=myhome.BMILDA noprint;
    class AGE;
    var BMI;
    output out=age_variance (drop=_TYPE_ _FREQ_) var=Variance_BMI;
run;


/* Plot the variance of BMI by AGE */
proc sgplot data=age_variance;
    series x=AGE y=Variance_BMI / markers lineattrs=(thickness=2);
    xaxis label='Age';
    yaxis label='Variance of BMI';
    title 'Variance of BMI by Age';
run;


/* Define an attribute map to control line colors */
proc template;
    define statgraph bmicolors;
        begingraph;
        entrytitle 'Mean BMI by Age and Smoking Status';
        layout overlay;
            seriesplot x=AGE y=Mean_BMI / group=SMOKING lineattrs=(thickness=2) name="BMI" markerattrs=(symbol=circlefilled);
            discretelegend "BMI" / title='Smoking Status';
        endlayout;
        endgraph;
    end;
run;

/* Create an attribute map dataset for customizing colors based on the smoking status */
data attrmap;
    length value $8 color $20;
    id='smoking_status';
    value='0'; color='blue'; output;
    value='1'; color='red'; output;
run;

/* Assign the attribute map to the graph template */
proc sgrender data=mean_bmi_by_smoking template=bmicolors;
    dynamic _ATTRS='attrmap' _STATS='smoking_status';
run;


proc gplot data=myhome.BMILDA;
	plot BMI*AGE / haxis=axis1 vaxis=axis2;
	symbol c=red i=std1mjt w=2 mode=include;
	axis1 label=(h=2 ’Age (years)’) value=(h=1.5) order=(10 to 100 by 10) minor=none;
	axis2 label=(h=2 A=90 ’BMI’) value=(h=1.5) order=(10 to 50 by 5)
	minor=none;
	title 'Average evolution, with standard errors of means';
run;quit;


/* First, calculate the smoking percentage for each individual */
proc sql;
    create table smoking_percentage as
    select ID, (sum(SMOKING) / count(SMOKING)) * 100 as Smoking_Percent
    from myhome.BMILDA
    group by ID;
quit;

/* Merge the smoking percentage back to the original dataset */
proc sql;
    create table BMILDA_with_smoking as
    select a.*, b.Smoking_Percent
    from myhome.BMILDA as a
    left join smoking_percentage as b
    on a.ID = b.ID;
quit;

/* Sort the data by ID to prepare for BY-group processing */
proc sort data=BMILDA_with_smoking;
    by ID;
run;


ods output ParameterEstimates=reg_params;
proc glm data=myhome.BMILDA;
    model BMI = Time SMOKING Time*SMOKING / solution;
    by ID;
    output out=estimates p=predicted_values r=residuals;
run;
ods output close;




/* Merge the additional variables back with the regression estimates */
proc sql;
    create table final_results as
    select a.ID, b.FAGE, b.SEX, b.SMOKING, 
           a.Intercept, a.Time, a.Time_SMOKING /* Replace with actual variable names from reg_params */
    from estimates as a
    inner join (select distinct ID, FAGE, SEX, SMOKING from BMILDA_with_smoking) as b
    on a.ID = b.ID;
quit;


