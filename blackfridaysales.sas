
LIBNAME Project "C:\Users\HOME10\Desktop\SAS";
DATA Project.Test;
INFILE;
RUN;
PROC IMPORT OUT=Project.Train 
            DATAFILE= "C:\Users\HOME10\Desktop\SAS\Project Data Files\10. Black Friday Data\train.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
     GUESSINGROWS=1000; 
RUN;
*since we have 2 dataset for this project we will first combine both dataset;
data Project.Black_Friday;
   set Project.Train Project.Test;
run;
*PROPERITIES OF YOUR DATA SET;

PROC CONTENTS DATA = Project.Black_Friday;
RUN;
PROC CONTENTS DATA = Project.Black_Friday VARNUM;
RUN;
*COLUMN NAMES;
PROC CONTENTS DATA = Project.Black_Friday VARNUM SHORT;
RUN;

DATA Project.Black_Friday_New(DROP = Product_Category_1 Product_Category_2 Product_Category_3); 
SET Project.Black_Friday;
RUN;
proc sql;
    create table Project.blackfriday_new as
    select User_ID,Gender, Age, Occupation, City_Category, Stay_In_Current_City_Years, Marital_Status,sum(purchase) as total_purchase
    from Project.Black_Friday_New
    group by User_ID;
quit; 
proc sql;
	create table project.blac_fri as
	select distinct*
	from Project.blackfriday_new;
quit;

*DESCRIPTIVE STATISTICS;
PROC MEANS DATA = project.blac_fri;
 VAR total_purchase;
RUN; 
proc freq data=project.black_friday order=freq;
tables product_id / noprint out=counts;
run;
data project.want;
set counts (obs=5);
run;
*Gender Frequency;
PROC FREQ DATA = project.blac_fri ;
 TABLE Gender;
RUN;
*USE Age Frequency;
PROC FREQ DATA = project.blac_fri;
 TABLE Age;
RUN;
*univarite;
PROC UNIVARIATE DATA =project.blac_fri;
 VAR Total_purchase;
 HISTOGRAM;
RUN;
PROC UNIVARIATE DATA =project.blac_fri;
 VAR occupation;
 HISTOGRAM;
RUN;
PROC UNIVARIATE DATA =project.blac_fri;
 VAR marital_status;
 HISTOGRAM;
RUN;
 
*Bivariate Continous and cartegorical;
*Gender/purchase;
proc anova data = project.blac_fri;
class gender;
model total_Purchase = gender;
run;
*Age/Purchase;
proc anova data = project.blac_fri;
class Age;
model total_Purchase = Age;
run;
*City_Category/Purchase;
proc anova data = project.blac_fri;
class CITY_CATEGORY;
model total_Purchase = CITY_CATEGORY;
run;
*Stay_In_Current_City_Years/Purchase;
proc anova data = project.blac_fri;
class Stay_In_Current_City_Years;
model total_Purchase = Stay_In_Current_City_Years;
run;
*Bivariate Continous and continous;
*Marital_status&Occupation/total_purchase;
PROC CORR DATA = project.blac_fri ;
 VAR marital_status occupation;
 WITH total_purchase;
RUN;

*Bivariate Categorical and categorical;
PROC FREQ DATA = project.black_friday;
 TABLE Age * Product_Id/CHISQ NOCOL NOROW  ;
RUN;
*Bivariate Categorical and categorical;
PROC FREQ DATA = project.black_friday;
 TABLE Gender* Product_Id/CHISQ NOCOL NOROW  ;
RUN;

*Creare Sql Queries to get the total count of each product ID;
proc sql;
    create table Project.blackfriday_N as
    select product_id,count(product_id) as total_num__of_product
    from Project.Black_Friday_New
    group by product_id;
quit; 
proc sql;
	create table project.blackfriday2N as
	select distinct*
	from Project.blackfriday_N;
quit;
proc sort data= project.blackfriday2N out = project.Sorted
DUPOUT=Product_ID
 NODUPKEY ;
by DESCENDING total_num__of_product;
run;

*Top 10 purchase;
proc print data=Project.sorted(obs=10);
run;
*mean,Min and max purchase for variable total_num__of_purchase;
proc means data =project.sorted;
var total_num__of_product;
run;
*Create a barchart to get of the top 10 product;
*Create format for easy usage of purchase values;
PROC FORMAT;
    VALUE INCOME
	  LOW   -< 50000 = "Low"
	  50000 -< 2000000 = "Middle"
	  2000000 -< 6000000   = "High"
      6000000 -HIGH  ='Very High';
RUN;
PROC FORMAT;
    VALUE INCOMEY
	  LOW   -< 100 = "Low"
	  100 -< 1000 = "Middle"
	  1000 -<10000   = "High"
      10000 - HIGH  ='Very High';
RUN;
proc freq data=project.blac_fri;
table age ;
run;
PROC FORMAT;
 VALUE $Age    "0-17" 	 = 0
 			   "18-25"   = 1
			   "26-35"   = 2
			   "46-50"   = 3
			   "51-55"   = 4
			   "55+"     = 5

;
RUN;

proc SGPLOT data = project.black_friday;
format purchase INCOMEY.;
vbar Gender/group = purchase GROUPDISPLAY = CLUSTER;
title 'Cluster of purchase by gender';
run;
proc SGPLOT data = project.blac_fri;
format total_purchase INCOME.;
vbar Gender/group = total_purchase GROUPDISPLAY = CLUSTER;
title 'Cluster of purchase by gender';
run;
proc SGPLOT data = project.blac_fri;
format total_purchase INCOME.;
vbar occupation/group = total_purchase GROUPDISPLAY = CLUSTER;
title 'Cluster of purchase by gender';
run;
proc sgplot data=project.black_friday;
scatter x=gender y= purchase ;
xaxis label=' Gender' ;
format purchase INCOMEY. ;
run;
quit;

PROC MEANS DATA = project.black_friday;
 VAR purchase;
RUN; 
PROC FREQ DATA = project.blac_fri ;
 TABLE total_purchase;
 format purchase INCOME.;
RUN;


*CALCULATE QUARTILES AND INTER QUARTILES;

PROC MEANS DATA = project.blac_fri MAXDEC=2 ;
 VAR total_purchase;
 OUTPUT OUT=project.TEMP P25 =Q1 P75 = Q3 QRANGE = IQR;
RUN;
DATA project.TEMP1;
 SET project.TEMP;
 LOWER_LIMIT = Q1 - (3*IQR);
 UPPER_LIMIT = Q3 + (3*IQR);
 DROP _TYPE_ _FREQ_;
RUN;

PROC PRINT DATA = TEMP1;
RUN;

*SAMPLING;
*srs =SIMPLE RANDOM SAMPLING;
PROC SURVEYSELECT DATA = project.blac_fri OUT=project.blackfriday_SAMPLE METHOD = SRS SAMPRATE= .3 SEED = 9876;
RUN;
PROC FREQ DATA = project.blackfriday_SAMPLE;
 TABLE total_purchase;
RUN;

PROC SORT DATA =  project.blac_fri OUT= project.blac_fri_sort;
 BY total_purchase;
RUN;
PROC SURVEYSELECT DATA = project.blac_fri_sort  OUT= project.blac_fri_SAMPLE METHOD = SRS SAMPSIZE = 1 SEED = 9876;
STRATA total_purchase;
RUN;
PROC FREQ DATA = project.blac_fri_SAMPLE;
 TABLE total_purchase;
RUN;
* TRAINING VS TEST : 70 30%;

PROC SURVEYSELECT DATA =project.blac_fri_sort
OUT= project.black_fri_SAMPLE  RATE = .3 OUTALL;
RUN;

PROC FREQ DATA = project.black_fri_SAMPLE;
 TABLE SELECTED;
RUN;
*proc logistic to predict total purchase amount;
proc logistic DATA = project.blac_fri_sort (obs=100);
class gender age(ref='26-35') /param = ref;;
model total_purchase=age marital_status Occupation gender / rsq lackfit;
run;

