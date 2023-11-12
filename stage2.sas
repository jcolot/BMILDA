libname myhome '/home/u59906376/';

/* Fit a two-level hierarchical linear model */


/* Merge the additional variables back with the regression estimates */
proc sql;
    create table ds as
    select * from myhome.final_results_stage_1 where time_effect <> 0;
quit;

proc means data=ds;
    var age_effect;
run;

ods latex file='/home/u59906376/stage_2_results_intercept.tex';
proc mixed data=ds method=ml;
   model Intercept = FAGE SEX / solution;
run;

ods latex close

ods latex file='/home/u59906376/stage_2_results_time.tex';
/* Fit a two-level hierarchical linear model */
proc mixed data=ds method=ml;
   model AGE_EFFECT = FAGE SEX / solution ;
run;
ods latex close

ods latex file='/home/u59906376/stage_2_results_smoking_efffect.tex';
/* Fit a two-level hierarchical linear model */
proc mixed data=ds method=ml;
   model SMOKING_EFFECT = FAGE SEX / solution;
run;
ods latex close

ods latex file='/home/u59906376/stage_2_results_smoking_time_effect.tex';
/* Fit a two-level hierarchical linear model */
proc mixed data=ds method=ml;
   model AGE_SMOKING_EFFECT = FAGE SEX / solution;
run;
ods latex close
