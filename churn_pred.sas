data check;
infile  "D:\sas_classexercise\Dataset_Cellphone.csv" dlm="," dsd flowover firstobs=2;
input 
Churn	$
AccountWeeks	$
ContractRenewal	$
DataPlan	$
DataUsage	$
CustServCalls	$
DayMins	$
DayCalls	$
MonthlyCharge	$
OverageFee	$
RoamMins	$
;
run;
proc print data=check obs=30;
run;
data final;
set check;
AccountWeeks_num=	input(AccountWeeks	,best12.);
ContractRenewal_num	=input(ContractRenewal	,best12.);
DataPlan_num	=input(DataPlan	,best12.);
DataUsage_num=	input(DataUsage	,best12.);
CustServCalls_num	=input(CustServCalls	,best12.);
DayMins_num=	input(DayMins	,best12.);
DayCalls_num=	input(DayCalls	,best12.);
MonthlyCharge_num	=input(MonthlyCharge	,best12.);
OverageFee_num	=input(OverageFee	,best12.);
RoamMins_num	=input(RoamMins	,best12.);
Drop 
AccountWeeks
ContractRenewal
DataPlan
DataUsage
CustServCalls
DayMins
DayCalls
MonthlyCharge
OverageFee
RoamMins
;
run;
proc contents data =final;
run;
proc freq data=final;
table Churn;
run;
PROC MEANS DATA=FINAL;
RUN;
PROC SURVEYSELECT DATA=FINAL METHOD=SRS SAMPRATE=0.6 OUT=TRAIN;
RUN;

Data validation;
merge final(in=a) train(in=b);
if a and not b;
run;

/*to check churn rate across train and validation datasets*/
proc freq data=train;
table churn;
run;

proc freq data=validation;
table churn;
run;


/*plain vanila model*/
proc logistic data=train;
model churn= AccountWeeks_num
ContractRenewal_num
DataPlan_num
DataUsage_num
CustServCalls_num
DayMins_num
DayCalls_num
MonthlyCharge_num
OverageFee_num
RoamMins_num;
run;



/*step wise model*/
proc logistic data=train outmodel=outmod desc;
model churn= AccountWeeks_num
ContractRenewal_num
DataPlan_num
DataUsage_num
CustServCalls_num
DayMins_num
DayCalls_num
MonthlyCharge_num
OverageFee_num
RoamMins_num/ selection= stepwise;
output out=outreg p=predicted;
run;



proc logistic inmodel=outmod;
score data=validation out=validation_scored;
run;




proc freq data=validation_scored;
table churn*P_1/ noprint measures;
run;

ods graphics on;
proc univariate data=outreg;
var predicted;
run;


proc print data=outreg obs=30;
run;

proc means data=outreg n;
where predicted>=0.5;
run;
Data outreg_final;
set outreg;
if predicted >=0.5 then churn_pred=1;
else churn_pred=0;
run;

/* confusion  matrix*/
proc freq data=outreg_final;
table churn_pred*churn;
run;



proc sort data=outreg_final;
by predicted;
run;

data bin;
do i=1 to 10;
    do j= 1 to 200;
    output;
 end;
 end;
 drop j;
 run;

proc print data=outreg_final;
run;





proc print data=binning;
run;

data outreg_final;
set outreg_final;
churn1=input(churn,best12.);
drop churn_num;
run;



proc print data=binning;
where i=3;
run;

data binning;
merge outreg_final bin;
run;

proc sql;
create table summary as
select i as binned, sum(churn1=1) as churns
from binning
group by i;
quit;



proc print data=summary;
run;


PROC EXPORT DATA= work.summary

OUTFILE= "D:\sas_classexercise\lifts.xls"

 DBMS=EXCEL2010 REPLACE;

    RUN;














