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
