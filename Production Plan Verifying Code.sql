-------------We want to verify the process being used for the production plan
---Potential issues with data intake
        --New placement is done before harvest is inputted - Issue #1
------------------------------------------------------------------------------------------------------------------------------------------
----This code houses our production planner flow
--Goal: Pulls in data from email repositories that get fed from the VBA program Matt Built
--Date: 1/8/2019
----Members: Matt Moscatel, Mason Lenz
------------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------------
--Mitto Flow outline
---Steps 1-5 loading table from emails for "User Placements"
	---This houses the placements for new rooms * First in flow
------------------------------------------------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------------------------------------------------
---1) SQL_DROP_TABLE_USER_PLACEMENT:Creates the table to house the new data to insert into placement new tables
create or replace table DEMO_DB."PRODUCTION_PLAN".mitto_user_placements
(__index__ FLOAT, strain_name string, quantity float, Facility string, Room string, begin_placement_date date, end_placement_date date, __source__ string, __mtime__ datetime );

---2) imap_cresco_room: Pulls in the data from the emails into mitto structure
{
    "credentials": {
        "password": "Yof26305",
        "username": "Cresco.Room@crescolabs.com"
    },
    "filename_format": "{safe_root}",
    "label": "inbox",
    "server": "outlook.office365.com"
}


---3) xlsx_upload_user_placement: Pulls in the data from the mitto structure and places into snowflake table "mitto_user_Placements"
{
    "input": {
        "regex": "user_placements_.*",
        "start_column": 0,
        "start_row": 0,
        "base": "flatfile.iov2#ExcelInput",
        "use": "flatfile.iov2#RegexInput"
    },
    "output": {
        "dbo": "snowflake://joelszuar:Zuar2019@ic98909/DEMO_DB",
        "schema": "PRODUCTION_PLAN",
        "tablename": "mitto_user_placements",
        "use": "call:mitto.iov2.db#todb"
    },
    "steps": [
        {
            "transforms": [
                {
                    "use": "mitto.iov2.transform#ExtraColumnsTransform"
                },
                {
                    "use": "mitto.iov2.transform#ColumnsTransform"
                }
            ],
            "use": "mitto.iov2.steps#Input"
        },
        {
            "use": "mitto.iov2.steps#CreateTable"
        },
        {
            "transforms": [
                {
                    "use": "mitto.iov2.transform#FlattenTransform"
                }
            ],
            "use": "mitto.iov2.steps#Output"
        },
        {
            "use": "mitto.iov2.steps#CountTable"
        }
    ]
}


---4) cmd_delete_users_placement_files: Deletes any placement files that are left in the mitto structure so they arnt pulled in again!
{
    "cmd": "rm -f /var/mitto/data/user_placements_*",
    "shell": true
}



---5) sql_user_placement_drop_null: Deletes any data that was entered incorrectly to make sure nothing gets messed up in placement new!
delete from DEMO_DB.PRODUCTION_PLAN.MITTO_USER_PLACEMENTS where facility is null;
------------------------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------------------------
---Steps 6-17 Moving the new data that got inserted into placement new and updating things to verify everyting comes in correctly
	---This is all done in SQL in snowflake
------------------------------------------------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------------------------------------------------
---6) sql_placement_pt1: Inserts the new rows for the new placement group! this comes from the mitto_user_placements we made earlier

insert into "DEMO_DB"."PRODUCTION_PLAN"."PLACEMENT_NEW" (Strain, Placement_Count, count, Facility, Room, Start_Placement, Plant_Placement)
select strain_name, quantity, quantity, FACILITY, room, begin_placement_date, end_placement_date
from DEMO_DB.PRODUCTION_PLAN.MITTO_USER_PLACEMENTS
where strain_name is not null;

---7) sql_placement_pt2: Updates table to add ready for sale date and sets Yield mod as 1
---Current ready for sale date - 84 days
---Current Yield Mod = 1

update DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW
set READY_FOR_SALE = DATEADD(day, 84, START_PLACEMENT),
"Yield_Mod" = 1,
SOURCE = 'Production Tool'
where READY_FOR_SALE is null;

---8) sql_placement_pt2.5: Updates table to insert the predicted next placement date from the previous harvest as "Predicted placement date" for the new line item

update DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW a
set a.PREDICTED_PLACEMENT_DATE = b.predicted_next_placement_Date
from (select room, facility, max(predicted_next_placement_Date) as predicted_next_placement_Date from DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW where harvest_date is not null group by room, facility) b
where a.predicted_placement_Date is null
and a.facility = b.facility
and a.room = b.room
;


---9) sql_placement_pt2.75: Updates table to insert the "Predicted placement date" for the new line items that did not get one from the previous query
	--Basically this is a catch for any placements that did not have any previous placements in placement new for that room/location

UPDATE "DEMO_DB"."PRODUCTION_PLAN"."PLACEMENT_NEW" SET "PREDICTED_PLACEMENT_DATE" = "PLANT_PLACEMENT" where "PREDICTED_PLACEMENT_DATE" is null
;


---10) sql_placement_pt3: Updates table to insert the "Predicted next placement date" by adding the "Days" from "Next placement values" where type = 'Next_Placement' and facility is the same

update DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW e
set e.predicted_next_placement_date = DATEADD(day,f.days,e.plant_placement)
from DEMO_DB.PRODUCTION_PLAN.NEXT_PLACEMENT_VALUES f
where e.predicted_next_placement_date is null
and e.Facility = f.location
and f.type = 'Next_Placement'
;



---11) sql_placement_pt4: Updates table "Predicted harvest date" by adding the "Days" from "Next placement values" where type = 'Harvest' and facility is the same

update DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW e
set e.predicted_harvest_date = DATEADD(day,f.days,e.start_placement)
from DEMO_DB.PRODUCTION_PLAN.NEXT_PLACEMENT_VALUES f
where e.predicted_harvest_date is null
and e.Facility = f.location
and f.type = 'Harvest'
;

---12) sql_placement_pt5: Updates table to insert the "Trigger_Date_1" as "Days" from "Next placement values" where type = 'Trig1' and facility is the same

update demo_db.PRODUCTION_PLAN.placement_new g
set g.trigger_date_1 = f.days
from DEMO_DB.PRODUCTION_PLAN.NEXT_PLACEMENT_VALUES f
where g.trigger_date_1 is null
and g.facility = f.location
and f.type = 'Trig1'
 ;


---13) sql_placement_pt6: Updates table to insert the "Trigger_Date_2" as "Days" from "Next placement values" where type = 'Trig2' and facility is the same

update demo_db.PRODUCTION_PLAN.placement_new g
set g.trigger_date_2 = f.days
from DEMO_DB.PRODUCTION_PLAN.NEXT_PLACEMENT_VALUES f
where g.trigger_date_2 is null
and g.facility = f.location
and f.type = 'Trig2'
 ;

---14) sql_placement_pt7: Updates table to insert the "Trigger_Date_3" as "Days" from "Next placement values" where type = 'Trig3' and facility is the same

update demo_db.PRODUCTION_PLAN.placement_new g
set g.trigger_date_3 = f.days
from DEMO_DB.PRODUCTION_PLAN.NEXT_PLACEMENT_VALUES f
where g.trigger_date_3 is null
and g.facility = f.location
and f.type = 'Trig3'
 ;

---15) sql_placement_pt8: Updates table "Clone" as "Days" from "Next placement values" where type = 'Clone' and facility is the same

update demo_db.PRODUCTION_PLAN.placement_new g
set g.clone = f.days
from DEMO_DB.PRODUCTION_PLAN.NEXT_PLACEMENT_VALUES f
where g.clone is null
and g.facility = f.location
and f.type = 'Clone'
 ;
---16) sql_placement_pt9: Updates table "Vegetative" as "Days" from "Next placement values" where type = 'Vegetative' and facility is the same

update demo_db.PRODUCTION_PLAN.placement_new g
set g.vegetative = f.days
from DEMO_DB.PRODUCTION_PLAN.NEXT_PLACEMENT_VALUES f
where g.vegetative is null
and g.facility = f.location
and f.type = 'Vegetative'
 ;

---17) sql_placement_pt10: Updates table and updates the room so it is no longer a float - this occurs when we pull the data in from mitto's file structure

update demo_db.PRODUCTION_PLAN.placement_new g
set room = case when room like '%.0%' then cast(cast(room as int) as string) else room end
 ;
------------------------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------------------------
---Steps 18-24 This is the beginning of the "Adjustments" portion of our code: anytime a plant count in a room is changes prior to harvest we record that with a reason in the adjustments table
	---This is all done in SQL in snowflake
------------------------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------------------------
---18) sql_drop_table_user_adjustment: Drops and re-creates the table "Mitto_User_Adjustements"

create or replace table DEMO_DB."PRODUCTION_PLAN".mitto_user_adjustment
(__index__ FLOAT, facility string, room string, strain string, number_removed float, reason string, comments string, __source__ string, __mtime__ datetime );


---19) imap_cresco_adjust: Pulls in the data from the emails and drops them into mitto structure

{
    "credentials": {
        "password": "Wam78971",
        "username": "Cresco.Adjust@crescolabs.com"
    },
    "filename_format": "{safe_root}",
    "label": "inbox",
    "server": "outlook.office365.com"
}

---20) xlsx_upload_user_adjustment: Inserts data from mitto structure into snowflake!

{
    "input": {
        "regex": "user_adjustment_.*",
        "start_column": 0,
        "start_row": 0,
        "base": "flatfile.iov2#ExcelInput",
        "use": "flatfile.iov2#RegexInput"
    },
    "output": {
        "dbo": "snowflake://joelszuar:Zuar2019@ic98909/DEMO_DB",
        "schema": "PRODUCTION_PLAN",
        "tablename": "mitto_user_adjustment",
        "use": "call:mitto.iov2.db#todb"
    },
    "steps": [
        {
            "transforms": [
                {
                    "use": "mitto.iov2.transform#ExtraColumnsTransform"
                },
                {
                    "use": "mitto.iov2.transform#ColumnsTransform"
                }
            ],
            "use": "mitto.iov2.steps#Input"
        },
        {
            "use": "mitto.iov2.steps#CreateTable"
        },
        {
            "transforms": [
                {
                    "use": "mitto.iov2.transform#FlattenTransform"
                }
            ],
            "use": "mitto.iov2.steps#Output"
        },
        {
            "use": "mitto.iov2.steps#CountTable"
        }
    ]
}
---21) cmd_delete_users_adjustment_files: Deletes files from mitto structure that have adjustments in the name

{
    "cmd": "rm -f /var/mitto/data/user_adjustment_*",
    "shell": true
}


---22) sql_adjustment_pt1: Adjusts the count of plants based on the join of (Facility, room, strain) and harvest date is null
----How can we adjust the code to





Update "DEMO_DB"."PRODUCTION_PLAN"."PLACEMENT_NEW" a
set a.count = a.count - l.number_removed
from (select a.FACILITY, a.room, a.strain, a.number_removed, a.reason, a.comments from DEMO_DB.PRODUCTION_PLAN.MITTO_USER_ADJUSTMENT a group by a.FACILITY, a.room, a.strain, a.number_removed, a.reason, a.comments) l
where a.Facility = l.FACILiTY
and a.room = l.room
and a.Strain = l.strain
  and concat(a.FACILITY,a.room, a.strain, a.PLANT_PLACEMENT) = (select concat(FACILITY,room, strain, min(PLANT_PLACEMENT) ) from DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW where HARVEST_DATE is null group by FACILITY, room, strain)
and a.Harvest_Date is null
;

---23) sql_adjustment_pt2: Inserts Change log of what occured and when with an associated reason, strain, room, facility, date, and comment




insert into "DEMO_DB"."PRODUCTION_PLAN"."CHANGE_LOG" (DATE ,Facility, Room, Strain, Change, Reason, Comment)
select CURRENT_TIMESTAMP() ,l.FACILITY, l.room, l.strain, l.number_removed, l.reason, l.comments
from (select a.FACILITY, a.room, a.strain, a.number_removed, a.reason, a.comments from DEMO_DB.PRODUCTION_PLAN.MITTO_USER_ADJUSTMENT a group by a.FACILITY, a.room, a.strain, a.number_removed, a.reason, a.comments) l
where FACILITY = l.FACILITY
and strain = l.strain
and room = l.room
;


---24) sql_adjustment_pt3: Sets the Weight in the change log, which denotes how many did we start with to see the comparison - Updates "Change log"

update "DEMO_DB"."PRODUCTION_PLAN"."CHANGE_LOG" a
set a.weight = l.placement_count
from (select a.FACILITY, a.room, a.strain, a.placement_count from DEMO_DB.PRODUCTION_PLAN.placement_new a where harvest_start is null group by a.FACILITY, a.room, a.strain, a.placement_count) l
where a.FACILITY = l.FACILITY
and a.strain = l.strain
and a.room = l.room
and a.weight is null;
------------------------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------------------------
---Steps 25-END This is the beginning of the "Harvest" portion of our code: anytime a room is closed out for harvest we have users input the harvest date and start of harvest dates
	---This is all done in SQL in snowflake
------------------------------------------------------------------------------------------------------------------------------------------

---25) sql_drop_table_user_harvest: Create and replaces what is the in the mitto_user_harvest table to clear last results from previous run

create or replace table DEMO_DB."PRODUCTION_PLAN".mitto_user_harvest (__index__ FLOAT, facility string, room string, begin_harvest_date date, end_harvest_date date, __source__ string, __mtime__ datetime );

---26) imap_cresco_harvest: Pulls in data from email to mitto structure

{
    "credentials": {
        "username": "Cresco.Harvest@crescolabs.com",
        "password": "Par21350"
    },
    "filename_format": "{safe_root}",
    "label": "inbox",
    "server": "outlook.office365.com"
}

---27) xlsx_upload_user_harvest: Inserts data from the mitto files into the snowflake structure

{
    "input": {
        "regex": "user_harvest_.*",
        "start_column": 0,
        "start_row": 0,
        "base": "flatfile.iov2#ExcelInput",
        "use": "flatfile.iov2#RegexInput"
    },
    "output": {
        "dbo": "snowflake://joelszuar:Zuar2019@ic98909/DEMO_DB",
        "schema": "PRODUCTION_PLAN",
        "tablename": "mitto_user_harvest",
        "use": "call:mitto.iov2.db#todb"
    },
    "steps": [
        {
            "transforms": [
                {
                    "use": "mitto.iov2.transform#ExtraColumnsTransform"
                },
                {
                    "use": "mitto.iov2.transform#ColumnsTransform"
                }
            ],
            "use": "mitto.iov2.steps#Input"
        },
        {
            "use": "mitto.iov2.steps#CreateTable"
        },
        {
            "transforms": [
                {
                    "use": "mitto.iov2.transform#FlattenTransform"
                }
            ],
            "use": "mitto.iov2.steps#Output"
        },
        {
            "use": "mitto.iov2.steps#CountTable"
        }
    ]
}


---28) cmd_delete_users_harvest_files: Deletes files with harvest in name from the mitto structure to verify we dont pull them again

{
    "cmd": "rm -f /var/mitto/data/user_harvest_*",
    "shell": true
}

---29) sql_harvest_pt1: Updates placement new with the "Harvest Start" and "Harvest Date" fields
	---THis is pulled from the excel tool so the dates are hard coded by cultivation directors

Update "DEMO_DB"."PRODUCTION_PLAN"."PLACEMENT_NEW" a
set a.Harvest_Start = ly.BEGIN_HARVEST_DATE, a.Harvest_Date = ly.end_harvest_date
from
(select a.BEGIN_HARVEST_DATE, a.END_HARVEST_DATE, a.room, a.FACILITY  from DEMO_DB.PRODUCTION_PLAN.MITTO_USER_HARVEST a
   group by  a.BEGIN_HARVEST_DATE, a.END_HARVEST_DATE, a.room, a.FACILITY) ly
where a.FACILITY = ly.FACILITY
and a.room = ly.room

 and concat(a.FACILITY, a.room, a.START_PLACEMENT) = (select concat(facility,room, min(START_PLACEMENT)) from DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW where HARVEST_DATE is null group by facility, room)

  and a.harvest_date is null;

----POTENTIAL IMPROVEMENTS: We could make sure that it is only closing out the min placement date for that room where harvest start is null
select * from DEMO_DB.PRODUCTION_PLAN.MASTER_STRAIN_CLEANER ---where type is null
select count(*) from ANALYTICS_DB.PRODUCTION_PLAN.CLEANER_STRAINS



drop table ANALYTICS_DB.PRODUCTION_PLAN.CLEANER_STRAINS;

---30) sql_strain_name_cleanup: Cleans the strain names in the code before finalizing flow

update demo_db.PRODUCTION_PLAN.PLACEMENT_NEW p
set p.strain_type = c.type, p.strain = c.strain
from "DEMO_DB"."PRODUCTION_PLAN"."MASTER_CLEANER_STRAINS" c
where lower(p.strain) like c.keyword;







select * from ANALYTICS_DB.CULTIVATION.old_room_names_9_23_2019_timestamp where location = 'Lincoln'




select distinct newroom, room_name, location from ANALYTICS_DB.CULTIVATION.BT_PLANT_CYCLES where location = 'Lincoln'


select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.BIO_MANIFESTS






select distinct a.MANIFESTID, VENDORID, coalesce(name,MYVENDOR), Session_Date, TICKETID from ANALYTICS_DB.CULTIVATION.PLANT_PRODUCT_TRANSFER a
left join (select distinct manifestid, MYVENDOR, LEFT(to_timestamp(sessiontime),10) as Session_Date from FIVETRAN_DB.BT_JOLIET_PUBLIC.BIO_MANIFESTS) b
on a.MANIFESTID = b.MANIFESTID;


select * from DEMO_DB.PRODUCTION_PLAn.PLACEMENT_NEW where strain = 'Gorilla Train Haze'





