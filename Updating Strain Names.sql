

select * from DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW where STRAIN_TYPE is null

----Tasks: 1/21/2019
---Updating Strain Types for California strains
---Updating strain names for all others that dont have strain connections

select * from DEMO_DB.PRODUCTION_PLAN.MASTER_STRAIN_CLEANER order by __INDEX__ desc;

Insert into DEMO_DB.PRODUCTION_PLAN.MASTER_STRAIN_CLEANER
Select '%501st%' as keyword, '501st' as strain, '' as type, max(__index__)+1 as __index__
From DEMO_DB.PRODUCTION_PLAN.MASTER_STRAIN_CLEANER;








__INDEX__,KEYWORD,STRAIN,TYPE,KEYWORD,STRAIN,TYPE,__INDEX__
3,%501st%,501st,Hybrid,,,,
328,%dante%,Dantes Inferno,Indica,,,,
329,%do%si%crash%,Do Si Dos,Indica,,,,
305,%tangerine%kush%,Tangerine Orange,Indica,,,,
330,%tangerine%,Tangerine Orange,Indica,,,,
331,%707%h%,707 Headband,Indica,,,,
332,%greez%m%,Greez Monkey,Hybrid,,,,
333,%strawberry%cough%,Strawberry Cough Drop,Sativa,,,,
334,%purple%train%,Purple Trainwreck,Indica,,,,
335,%bisti%b%,Bisti Badlands,Indica,,,,
336,%cindy%white%,Cinderella 99,Sativa,,,,
337,%heisenherb%,Heisenherb,Indica,,,,
338,%jack%haze%,Jack's Haze,Sativa,,,,
339,%alien%straw%,Alien Strawberry,Sativa,,,,
340,%julius%c%,Julius Caesar,Hybrid,,,,
341,%tang%orang%,Tangerine Orange,Indica,,,,
342,%t%orange%,Tangerine Orange,Indica,,,,
343,%red%line%haze%,Red Line Haze,Sativa,,,,
344,%grape%ape%,Grape Ape,Indica,,,,



select * from ANALYTICS_DB.PRODUCTION_PLAN.CLEANER_STRAINS a
left join DEMO_DB.PRODUCTION_PLAN.MASTER_STRAIN_CLEANER b
on a.STRAIN = b.STRAIN
and a.KEYWORD = b.KEYWORD
where b.STRAIN is null

;





335
select * from DEMO_DB.PRODUCTION_PLAN.MASTER_STRAIN_CLEANER;
327
---where strain = 'Grape'



---where strain like ''
describe table DEMO_DB.PRODUCTION_PLAN.MASTER_STRAIN_CLEANER;

indica
sativa
hybrid
select



































