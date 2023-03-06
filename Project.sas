/* Project */

libname mylib "/home/u60694061/BAN110ZBB(DJ)";

/* 2. Loading data */
proc import datafile= "/home/u60694061/BAN110ZBB(DJ)/Project/AB1_NYC_2019.csv"
 out= mylib.ab_project;
 dbms = csv;
run;

proc print data= mylib.ab_project (obs=10);
run;

/* Dataset Charcteristics */
proc means data= mylib.ab_project;
run;

/* 3.1.1.	If categorical, show the frequency distribution of each of the possible values. 
Interpret. Is the dataset balanced? Any other comment? */

proc freq data= mylib.ab_project order=freq;
tables neighbourhood_group neighbourhood room_type;
run;

/* 3.1.2.	If numerical, show the statistics (min, max, mean) and the shape of the distribution through a histogram. */

proc univariate data=mylib.ab_project;
var price minimum_nights number_of_reviews reviews_per_month calculated_host_listings_count availability_365;
histogram / normal;
run;

/* 5. Numerical Variables */
/* -	Check errors (range of values/ less than/larger than). */
title "Range of values";
ODS select extremeobs quantiles;

proc univariate data= mylib.ab_project;
 id id;
 var last_review price minimum_nights number_of_reviews reviews_per_month;
 qqplot last_review price minimum_nights number_of_reviews reviews_per_month;
run;

/* Finding outliers */
proc print data=mylib.ab_project;
 where (price not between 30 and 8000 and price is not missing);
 id id;
 var price;
run;

/* Delete extreme observations */
data extobs_ny;
 set mylib.ab_project;
 
 if price <30 then 
  delete;
 else if price >8000 then
  delete;
run;

/* Evaluation after deleting extreme observations */
proc univariate data= extobs_ny;
 id id;
 var price;
 qqplot price;
run;

/* Removing missing dates */
data missingdate;
 set extobs_ny;
 if missing(last_review) then
  delete;
run;

proc print data=missingdate (obs=100);
 var last_review ;
run;

/* Finding outliers for Reviews Per Month */
proc print data= missingdate;
 where (reviews_per_month not between 0 and 20 and reviews_per_month is not missing);
 id id;
 var reviews_per_month;
run;

/* Delete extreme observations */
data extobs_rpm;
 set missingdate;
 
 if reviews_per_month < 1 then 
  delete;
 else if  reviews_per_month >20 then
  delete;
run;

/* Evaluation after deleting extreme observations */
proc univariate data= extobs_rpm;
 id id;
 var reviews_per_month;
 qqplot reviews_per_month;
run;

/* Checking the distribution of some numerical variables to decide which method to use for outlier detection */

Title "Boxplot of Price";

proc sgplot data= extobs_rpm;
  vbox price;
run;

Title "Boxplot of Reviews Per Month";

proc sgplot data= extobs_rpm;
  vbox reviews_per_month;
run;

/* Interquartile range to find and detect teh outliers */

title "Outliers Based on Interquartile Range";

proc means data= extobs_rpm noprint;
var price;
output out=Tmp
 Q1=
 Q3=
 QRange= / autoname;
run;

data _null_;
 file print;
 set extobs_rpm (keep=id price);
  if _n_ = 1 then set Tmp;
   if price le price_Q1 - 1.5*price_QRange and not missing(price)
or

price ge price_Q3 + 1.5*price_QRange then
 put "Possible Outlier for Price " id "Value
of price is "Price;
run;

/* Deleting the outliers of price using the Interquartile range method */

title "Deleting Outliers Based on Interquartile Range";

data final_price;
 file print;
 set extobs_rpm;
  if _n_ = 1 then set Tmp;
   if price le price_Q1 - 1.5*price_QRange and not missing(price)
or

price ge price_Q3 + 1.5*price_QRange then
 delete;
run;

title "Distribution of Price without outliers";

proc sgplot data= final_price;
 histogram price;
 density price;
run;

title "Box plot of price without outliers";

proc sgplot data= final_price;
 vbox price;
run;

proc print data= final_price(obs=10);
run;

/* Interquartile range to find and detect the outliers for revies per month*/

title "Outliers Based on Interquartile Range";

proc means data= final_price noprint;
var reviews_per_month;
output out=Tmp
 Q1=
 Q3=
 QRange= / autoname;
run;

data _null_;
 file print;
 set final_price;
  if _n_ = 1 then set Tmp;
   if reviews_per_month le reviews_per_month_Q1 - 1.5*reviews_per_month_QRange and not missing(reviews_per_month)
or

reviews_per_month ge reviews_per_month_Q3 + 1.5*reviews_per_month_QRange then
 put "Possible Outlier for reviews per month " id "Value
of reviews per month is "reviews_per_month;
run;

/* Deleting the outliers of reviews per month using the Interquartile range method */

title "Deleting Outliers of reviews per monthBased on Interquartile Range";

data final_abnyc;
 file print;
 set final_price ;
  if _n_ = 1 then set Tmp;
   if reviews_per_month le reviews_per_month_Q1 - 1.5*reviews_per_month_QRange and not missing(reviews_per_month)
or
reviews_per_month ge reviews_per_month_Q3 + 1.5*reviews_per_month_QRange then
 delete;
run;

title "Distribution of Price without outliers";

proc sgplot data= final_abnyc;
 histogram reviews_per_month;
 density reviews_per_month;
run;

title "Box plot of price without outliers";

proc sgplot data= final_abnyc;
 vbox reviews_per_month;
run;

/* Testing for normality again with histogram and QQ plot */
proc univariate data=final_abnyc;
 var reviews_per_month price;
 qqplot reviews_per_month price;
run;


