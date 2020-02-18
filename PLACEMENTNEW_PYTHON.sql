insert into "PLACEMENTNEW" (Strain, Placement_Count, count, Facility, Room, Start_Placement, Plant_Placement)
select strain_name, quantity, quantity, FACILITY, room, begin_placement_date, end_placement_date
from MITTO_USER_PLACEMENTS
where strain_name is not null;

--##STEP1 for python

update PLACEMENTNEW
set READY_FOR_SALE = DATEADD(day, 84, START_PLACEMENT),
"Yield_Mod" = 1,
SOURCE = 'Production Tool'
where READY_FOR_SALE is null;



update PLACEMENTNEW a set a.PREDICTED_PLACEMENT_DATE = b.predicted_next_placement_Date from (select room, facility, max(predicted_next_placement_Date) as predicted_next_placement_Date from PLACEMENTNEW where harvest_date is not null group by room, facility) b where a.predicted_placement_Date is null and a.facility = b.facility and a.room = b.room
;




UPDATE "PLACEMENTNEW" SET "PREDICTED_PLACEMENT_DATE" = "PLANT_PLACEMENT" where "PREDICTED_PLACEMENT_DATE" is null
;




update PLACEMENTNEW e set e.predicted_next_placement_date = DATEADD(day,f.days,e.plant_placement) from NEXT_PLACEMENT_VALUES f where e.predicted_next_placement_date is null and e.Facility = f.location and f.type = 'Next_Placement'
;

select * from DEMO_DB.PRODUCTION_PLAN.NEXT_PLACEMENT_VALUES


update PLACEMENTNEW e set e.predicted_harvest_date = DATEADD(day,f.days,e.start_placement) from NEXT_PLACEMENT_VALUES f where e.predicted_harvest_date is null and e.Facility = f.location and f.type = 'Harvest'
;





update PLACEMENTNEW g set g.trigger_date_1 = f.days from NEXT_PLACEMENT_VALUES f where g.trigger_date_1 is null and g.facility = f.location and f.type = 'Trig1'
 ;



update PLACEMENTNEW g set g.trigger_date_2 = f.days from NEXT_PLACEMENT_VALUES f where g.trigger_date_2 is null and g.facility = f.location and f.type = 'Trig2'
 ;



update PLACEMENTNEW g set g.trigger_date_3 = f.days from NEXT_PLACEMENT_VALUES f where g.trigger_date_3 is null and g.facility = f.location and f.type = 'Trig3'
 ;



update PLACEMENTNEW g set g.clone = f.days from NEXT_PLACEMENT_VALUES f where g.clone is null and g.facility = f.location and f.type = 'Clone'
 ;


update PLACEMENTNEW g set g.vegetative = f.days from NEXT_PLACEMENT_VALUES f where g.vegetative is null and g.facility = f.location and f.type = 'Vegetative'
 ;



update PLACEMENTNEW g set room = case when room like '%.0%' then cast(cast(room as int) as string) else room end
 ;













































select * from DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW where count is null



select  sum(TOTAL_WET_WEIGHT) / sum(TOTAL_PLANTS) as ww
from ANALYTICS_DB.BUSINESS.CULTIVATION_YIELDS
where LOCATION = 'Kankakee' and strain = 'Katsu Bubba Kush'
  and PLANNER_HARVEST_DATE >= '2019-04-01'
  and ROOM_NUMBER in ('Mini Bloom') ;


Update PLACEMENT_NEW
set count = ( select PLACEMENT_NEW.count - l.number_removed
from (select a.FACILITY, a.room, a.strain, a.number_removed, a.reason, a.comments from ADJUSTMENTS a group by a.FACILITY, a.room, a.strain, a.number_removed, a.reason, a.comments) l
where PLACEMENT_NEW.Facility = l.FACILiTY
and PLACEMENT_NEW.room = l.room
and PLACEMENT_NEW.Strain = l.strain
and concat(PLACEMENT_NEW.FACILITY,PLACEMENT_NEW.room, PLACEMENT_NEW.strain, PLACEMENT_NEW.PLANT_PLACEMENT) = (select concat(FACILITY,room, strain, min(PLANT_PLACEMENT) ) from DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW where HARVEST_DATE is null group by FACILITY, room, strain)
and PLACEMENT_NEW.Harvest_Date is null)
where Harvest_Date is null;


insert into "DEMO_DB"."PRODUCTION_PLAN"."CHANGE_LOG" (DATE ,Facility, Room, Strain, Change, Reason, Comment)
select CURRENT_TIMESTAMP() ,l.FACILITY, l.room, l.strain, l.number_removed, l.reason, l.comments
from (select a.FACILITY, a.room, a.strain, a.number_removed, a.reason, a.comments from DEMO_DB.PRODUCTION_PLAN.MITTO_USER_ADJUSTMENT a group by a.FACILITY, a.room, a.strain, a.number_removed, a.reason, a.comments) l
where FACILITY = l.FACILITY
and strain = l.strain
and room = l.room;

update "DEMO_DB"."PRODUCTION_PLAN"."CHANGE_LOG" a
set a.weight = l.placement_count
from (select a.FACILITY, a.room, a.strain, a.placement_count from DEMO_DB.PRODUCTION_PLAN.placement_new a where harvest_start is null group by a.FACILITY, a.room, a.strain, a.placement_count) l
where a.FACILITY = l.FACILITY
and a.strain = l.strain
and a.room = l.room
and a.weight is null;










