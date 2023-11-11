/* Assign a libname for your data location */
libname myhome '/home/u59906376/';

/* Step 1: Select a random subset of 500 individuals */
proc surveyselect data=myhome.BMILDA out=myhome.sampled_data method=srs
  sampsize=500 seed=12345; /* Seed for reproducibility */
run;

/* Step 2: Sort the sampled data by ID and TIME for plotting */
proc sort data=myhome.sampled_data;
  by ID TIME;
run;

/* Step 3: Set the graphics environment to generate PNG format (image is save under the name specified by imagename) */
ods graphics on / imagefmt=png imagename="spaghetti";

/* Step 4: Open the HTML5 destination to save the plot as a PNG file */
ods html5 file='/home/u59906376/spaghetti_plot.html' 
      gpath='/home/u59906376/';

/* Create the plot with all individuals in the same default blue color, with solid lines */
proc sgplot data=myhome.sampled_data noautolegend;
  series x=TIME y=BMI / group=ID lineattrs=(color=blue pattern=solid);
  xaxis label='Time';
  yaxis label='BMI';
  title 'Spaghetti Plot of BMI over Time for 500 Random Individuals';
run;

/* Step 5: Close the HTML5 destination */
ods html5 close;

/* Turn off ODS Graphics */
ods graphics off;
