libname myhome '/home/u59906376/';

/* Open ODS OUTPUT to capture the ParameterEstimates table */
ods output ParameterEstimates=reg_params;

proc glm data=myhome.BMILDA;
    model BMI = TIME SMOKING TIME*SMOKING / solution;
    by ID;
    output out=estimates p=predicted_values r=residuals;
run;

/* Close ODS OUTPUT to stop capturing tables */
ods output close;

/* Enable ODS output to the results window again */
ods select all;


proc transpose data=reg_params out=wide_params(drop=_NAME_);
    by ID;
    id Parameter;
    var Estimate;
run;



/* Merge the additional variables back with the regression estimates */
proc sql;
    create table final_results_stage_1 as
    select distinct a.ID, b.FAGE, b.SEX, a.SMOKING as SMOKING_EFFECT, /* Selecting SMOKING from table b */
           a.Intercept, a.TIME as TIME_EFFECT, a."TIME*SMOKING"n as TIME_SMOKING_EFFECT /* Using n literal for special column names */
    from wide_params as a
    inner join (select distinct ID, FAGE, SEX, SMOKING from myhome.BMILDA) as b
    on a.ID = b.ID;
quit;
