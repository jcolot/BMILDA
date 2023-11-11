libname myhome '/home/u59906376/';

/* Step 1: Sort and transpose the data to wide format */
proc sort data=myhome.BMILDA; 
  by ID TIME; 
run;

proc transpose data=myhome.BMILDA out=wideDf prefix=bmi;
  by ID;
  id TIME;
  var BMI;
run;

/* Step 2: Create a dataset with distinct covariate values for each ID */
data distinctDf;
  set myhome.BMILDA;
  by ID;
  if first.ID; /* Keep the first occurrence for each subject */
run;

/* Step 3: Merge the wide format BMI data with the distinct covariate data */
proc sort data=distinctDf;
  by ID; /* Make sure both datasets are sorted by ID before merging */
run;

data wideDf;
  merge wideDf (in=a) distinctDf (in=b rename=(BMI=bmi0 FAGE=fage SEX=sex SMOKING=smoking));
  by ID;
  if a; /* Ensures we only keep subjects that were in the wideDf dataset */
run;

/* Step 4: Filter for subjects with non-missing baseline and final measurements */
data filtBMI;
  set wideDf;
  if not missing(bmi0) and not missing(bmi9); /* Assuming bmi0 and bmi9 are the baseline and final time point measurements */
  diff_bmi = bmi9 - bmi0; /* Calculate the difference in BMI between the two time points */
run;



ods latex file='/home/u59906376/covariance.tex';
proc glm data=filtBMI;
   model bmi9 = bmi0 fage sex smoking / solution;
   title 'ANALYSIS OF COVARIANCE: Y = BMI_9; X0 = BMI_0';
run;
ods latex close;
quit;
