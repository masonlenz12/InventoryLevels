-----Start with flower run rate
    ----Timeframe for throughput is Time test passed to first unit put into transfers

select * from DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW where HARVEST_DATE is null

select avg(days_fifo), avg(days_filo), month(First_Test_DT) from
(
select avg(days_FIFO) as DAYS_FIFO, avg(Days_FILO) as DAYS_FILO, ORIGINATINGINVID, First_Test_DT, last_test_Dt, LOC,ROOM_NUMBER from
(select ORIGINATINGINVID,LOC,ROOM_NUMBER,min(INVENTORYTYPE) as start_type, max(INVENTORYTYPE) as end_type, min(TESTRESULTS1) as First_Test, min(SESSIONDATE) as First_Test_DT, max(sessiondate) as last_test_Dt, min(min_DT2) as First_Transfered_Out, ABS(DATEDIFF('days',min(min_DT2),max(SESSIONDATE))) as Days_FIFO,max(SESSIONDATE)-min(SESSIONDATE) as Days_FILO from ANALYTICS_DB.CULTIVATION.LEVEL_FINAL a
left join (select ORIGINATINGINVID as ORIGINATINGINVID2, min(sessiondate) min_DT2, max(SESSIONDATE) as max_dt2 from (select * from ANALYTICS_DB.CULTIVATION.LEVEL_FINAL where TRANSFERREDOUT = 1 order by SESSIONDATE desc) where INVENTORYTYPE = '28' and loc = 'JOL' group by ORIGINATINGINVID ) b
on a.ORIGINATINGINVID = b.ORIGINATINGINVID2
where TESTRESULTS1 is not null and INVENTORYTYPE in (6,13,28) and loc = 'JOL' and TESTRESULTS1 in ('Passed') and SESSIONDATE >= '2019-01-01' and INVENTORYROOM_NAME not like '%Waste%'  group by ORIGINATINGINVID, LOC,ROOM_NUMBER)  group by ORIGINATINGINVID, First_Test_DT, last_test_Dt, LOC,ROOM_NUMBER)
group by month(First_Test_DT)
;

select distinct MANIFESTID, VENDORID, name, TRANSFERDATE, TICKETID from ANALYTICS_DB.CULTIVATION.PLANT_PRODUCT_TRANSFER;

select * from ANALYTICS_DB.CULTIVATION.PLANT_PRODUCT_TRANSFER where MANIFESTID = '5205679193032850';

select * from ANALYTICS_DB.CULTIVATION.LEVEL_FINAL;
select * from DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW where HARVEST_DATE is null

select * from DEMO_DB.PRODUCTION_PLAN.NEXT_PLACEMENT_VALUES


select * from ANALYTICS_DB.CULTIVATION.MITTO_EXPECTED_WEIGHTS where strain = 'Rocket Fuel' and room = '133';








select * from FIVETRAN_DB.ASAHI_POSTGRES_PROD_PUBLIC.PRODUCTS where brand = 'Cresco';-- limit 50;
Durban Poison 1.0g BHO Wax
select * from DEMO_DB.PRODUCTION_PLAN.MASTER_STRAIN_CLEANER



--Regexp Example: '/(?=.*pre)(?=.*roll)/i'

select *  from ANALYTICS_DB.CULTIVATION.LEVEL_FINAL where PRODUCT_NAME = 'Gummy-Freshly Picked Berries 40mg 20ct Pouch (K)';
INVENTORY_ID
0231795384087610
8684716026169293

select INVENTORYROOM_NAME, SESSIONDATE as sessiondate,* from ANALYTICS_DB.CULTIVATION.LEVEL_FINAL order by LEFT(to_timestamp(SESSIONTIME),10) desc

select * from ANALYTICS_DB.CULTIVATION.BIOTRACK_CURRENT_INVENTORY where INVENTORYROOM_NAME like '%+%Edible%FG%'

select distinct lastuser from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY where INVENTORYTYPE = '22'

select distinct  b.CATEGORY_MATCH, b.SUB_CATEGORY, a.PRODUCT_NAME,  to_array(replace(b.sub_category, '_',','))
from  ANALYTICS_DB.CULTIVATION.LEVEL_FINAL a
    left join (select distinct category_match, sub_category from FIVETRAN_DB.ASAHI_POSTGRES_PROD_PUBLIC.ETL_CATEGORIES) b
    ON regexp_instr(lower(a.PRODUCT_NAME), lower(CONCAT('.*',replace(sub_category, '_','.*'),'.*'))) > 0
where a.PRODUCT_NAME is not null;


select distinct category_match, sub_category, CONCAT('.*',replace(sub_category, '_','.*'),'.*'), regexp_instr('Gummy-Glazed Clementine Orange 100mg 20ct Tin (K)' ,lower(CONCAT('.*',replace(sub_category, '_','.*|.*'),'.*'))) from FIVETRAN_DB.ASAHI_POSTGRES_PROD_PUBLIC.ETL_CATEGORIES

select distinct regexp_instr(PRODUCT_NAME, 'Material'), PRODUCT_NAME
from ANALYTICS_DB.CULTIVATION.LEVEL_FINAL
where PRODUCT_NAME is not null
  and PRODUCT_NAME like '%Material%';




-- where lower(PRODUCT_NAME) regexp '(.*pull.*)|(.*snap.*)'










select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORYTRANSFERS;

DAYS_FIFO,DAYS_FILO,ORIGINATINGINVID,FIRST_TEST_DT,LAST_TEST_DT,LOC,ROOM_NUMBER
,3.000000,0746314850624547,2019-11-23,2019-11-26,JOL,Zone 1
,28.000000,9480559349630298,2019-11-23,2019-12-21,JOL,Zone 1
,22.000000,6457455896054438,2019-11-27,2019-12-19,JOL,Zone 3
,23.000000,8733524891754414,2019-11-27,2019-12-20,JOL,Zone 3
,21.000000,4664295242629605,2019-12-02,2019-12-23,JOL,Zone 3
,36.000000,8560729184236759,2019-12-09,2020-01-14,JOL,Zone 4   ----12/09 until 1/14
,38.000000,2932403122424490,2019-12-11,2020-01-18,JOL,130
,38.000000,5016244184687145,2019-12-11,2020-01-18,JOL,130
,41.000000,8172474588455565,2019-12-11,2020-01-21,JOL,130
,38.000000,0372997943344138,2019-12-11,2020-01-18,JOL,130
,36.000000,2211736909870483,2019-12-16,2020-01-21,JOL,Zone 4
,24.000000,6634750926739394,2019-12-26,2020-01-19,JOL,131
,23.000000,2294039347129783,2019-12-26,2020-01-18,JOL,131
,9.000000,9795199907098823,2020-01-06,2020-01-15,JOL,232
,9.000000,3484483637765020,2020-01-06,2020-01-15,JOL,Zone 3
,7.000000,3266646991939925,2020-01-07,2020-01-14,JOL,Zone 3
DAYS_FIFO,DAYS_FILO,ORIGINATINGINVID,FIRST_TEST_DT,LAST_TEST_DT,LOC,ROOM_NUMBER
-22.000000,56.000000,4564480182032718,2019-03-07,2019-05-02,JOL,130


select * from ANALYTICS_DB.CULTIVATION.LEVEL_FINAL where ORIGINATINGINVID = '4564480182032718'


--update DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW
--set CULTIVATION_ENVIRONMENT =
--/*--Brookeville*/
--Case when facility = 'Brookville' and room like '%GH1%Bay%' THEN 'Greenhouse'
--when facility = 'Brookville' and room like '%Flower%' THEN 'Indoor'
/*---Carpinteria &*/
--when facility in ('Carpenteria','Carpinteria') THEN 'Greenhouse'
/*---Encanto*/
--WHEN facility = 'Encanto' and TRIM(RIGHT(trim(room),2)) in ('A','D','E','F','G', 'H', 'I') THEN 'Indoor'
--WHEN facility = 'Encanto' and TRIM(RIGHT(trim(room),2)) in ('GH') THEN 'Greenhouse'
/*---Fall River*/
--WHEN facility = 'Fall River' then 'Indoor'
/*---Joliet*/
--WHEN facility = 'Joliet' THEN 'Indoor'
/*---Kankakee*/
--WHEN facility = 'Kankakee' THEN 'Indoor'
/*---Lincoln*/
--WHEN facility = 'Lincoln' THEN 'Greenhouse'
/*---Vicksburg*/
--WHEN facility = 'Vicksburg' then 'Greenhouse'
/*---Yellow SPrings*/
--WHEN facility = 'Yellow Springs' and room like '%Greenhouse%' THEN 'Greenhouse'
--WHEN facility = 'Yellow Springs' and (room like '%Indr%' or room like '%Indoor%') then 'Indoor'
/*---MA*/
--WHEN FACILITY = 'Massachusetts' THEN 'Indoor'
--    ELSE CULTIVATION_ENVIRONMENT END;





----Live resin/vapes
    ----Timeframe from first lot until turned into oil
        ----Then from oil to first packout
















































Create or replace table ANALYTICS_DB.CULTIVATION.LEVEL9_INVENTORY as
select g.id as inventory_id, f.OriginatingInvID as OriginatingInvID,g.weight,g.SAMPLE_ID, g.REMAININGWEIGHT, g.TRANSFERREDOUT, g.TRANSFERREDOUTTIME, g.Strain, g.inventorytype, cast(to_timestamp(g.Sessiontime) as Date) as SessionDate, max(f.placementgroup) as placementgroup, max(Room_Number) as Room_number, max(room_front_back) as room_front_back, max(k.roomname) as InventoryRoom_Name, CONCAT(' ',cast(g.productid as string), ' ') as PRODUCTID, g.QUANTITY, g.LASTACTION,min(fh.Quantity) as Converted_Final_weiht2, max(fh.QUANTITY) as Converted_Final_Weight, fh.WASTE, min(fh.PARENT_QUANTITY_OLD) as Start_Quantity, max(fh.PARENT_QUANTITY_OLD) as end_quantity, min(INVENTORYID) as ConversionID, g.deleted, g.loc, LEFT(to_timestamp(g.created),10) as Created_Dt


from (select * from    (select *, trim(f.value, '"') as parentid_Join2
   from
 (select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, *, 'JOL' as LOC
 from
FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
     UNION
select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, *, 'KKE' as LOC from
FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
     UNION
select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, *, 'LNL' as LOC from
FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY



     ) ly, table(flatten(ly.parentid_join)) f) f

     ) g




left join ANALYTICS_DB.CULTIVATION.LEVEL8_INVENTORY f
on
 f.inventory_id = g.parentid_join2
left join (select * from    (select *, trim(f.value, '"') as parentid_Join3
   from
 (select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, *
 from
FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORYCONVERSIONS_WA
     UNION
select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, * from
FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORYCONVERSIONS_WA
     UNION
select  cast(SPLIT(cast(parentid as varchar), ',') as ARRAY) as parentid_join, * from
FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORYCONVERSIONS_WA



     ) ly, table(flatten(ly.parentid_join)) f) f
) fh on
 g.id = fh.parentid_Join3
left join (select *, 'JOL' as LOC from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORYROOMS UNION select *, 'LNL' as LOC from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORYROOMS UNION select *, 'KKE' as LOC from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORYROOMS ) k
on g.CURRENTROOM = k.id
and g.loc = k.loc
where (f.inventory_id is not null or f.conversionid is not null)
and f.inventory_id <> g.id
group by g.id , f.OriginatingInvID ,g.weight,g.SAMPLE_ID, g.REMAININGWEIGHT, g.TRANSFERREDOUT, g.TRANSFERREDOUTTIME, g.Strain, g.inventorytype, cast(to_timestamp(g.Sessiontime) as Date),  CONCAT(' ',cast(g.productid as string), ' '), g.QUANTITY,  g.LASTACTION,  fh.WASTE, g.deleted, g.loc, LEFT(to_timestamp(g.created),10);


alter table ANALYTICS_DB.CULTIVATION.LEVEL9_INVENTORY
add column batchno string;

update ANALYTICS_DB.CULTIVATION.LEVEL9_INVENTORY a
set a.batchno = b.batchno
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;

alter table ANALYTICS_DB.CULTIVATION.LEVEL9_INVENTORY
add column inventorystatus string;

update ANALYTICS_DB.CULTIVATION.LEVEL9_INVENTORY a
set a.inventorystatus = b.inventorystatus
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;




alter table ANALYTICS_DB.CULTIVATION.LEVEL9_INVENTORY
add column packageweight string;

update ANALYTICS_DB.CULTIVATION.LEVEL9_INVENTORY a
set a.packageweight = b.packageweight
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;


alter table ANALYTICS_DB.CULTIVATION.LEVEL9_INVENTORY
add column RoomType string;

update ANALYTICS_DB.CULTIVATION.LEVEL9_INVENTORY
set roomtype = case when InventoryRoom_Name like '%Cure Room%' THEN 'Dry Flower Lot'
when InventoryRoom_Name like '%Waste%' THEN 'Waste Lot'
when InventoryRoom_Name like '%Freeze%' THEN 'Fresh Frozen Lot'
when InventoryRoom_Name like '%BHO%' THEN 'BHO Lot'
when InventoryRoom_Name like '%CO2%' THEN 'CO2 Lot'
when InventoryRoom_Name like '%Ethanol%' THEN 'Ethanol Lot'
when InventoryRoom_Name like '%Extraction%' and InventoryRoom_Name like '%Vault%' THEN 'Extraction Lot'
when InventoryRoom_Name like '%Roman%' and InventoryRoom_Name like '%Vault%' THEN 'Roman Candle Lot'
when InventoryRoom_Name like '%Testing%' and InventoryRoom_Name like '%Vault%' THEN 'Tested Lot'
when InventoryRoom_Name like '%Vault%' and InventoryRoom_Name like '%+%' THEN 'Intermediate Mixed/Oils Lot'
when InventoryRoom_Name like '%Cold Room%' and InventoryRoom_Name like '%+%' THEN 'Intermediate Edibles Lot'
when InventoryRoom_Name like '%Extract%' and InventoryRoom_Name like '%-%' THEN 'Extraction Stage Lot'

when InventoryRoom_Name like '%Vault%' and InventoryRoom_Name like '%!%' THEN 'PackoutRetailer Lot'
when InventoryRoom_Name like '%Vault%' and InventoryRoom_Name like '%**%' THEN 'PackoutRetailer Lot'
when InventoryRoom_Name like '%-%' and left(InventoryRoom_Name,1) in ('5','4','6','3','2','1') THEN 'PackoutRetailer Lot'


when InventoryRoom_Name like '%Working%' or InventoryRoom_Name like '%Flower Vault%' THEN 'Dry Flower Lot'
    ELSE NULL END;

alter table ANALYTICS_DB.CULTIVATION.LEVEL9_INVENTORY
add column TestResults1 string;




update ANALYTICS_DB.CULTIVATION.LEVEL9_INVENTORY a
set TestResults1 = case when result = 1 THEN 'Passed' WHEN result = -1 then 'Failed' else 'No Test Results Yet' end
FROM (select id as sample_id, inventoryid, result from FIVETRAN_DB.BT_JOLIET_PUBLIC.BMSI_LABRESULTS_SAMPLES) g
where a.sample_id = g.inventoryid;


update ANALYTICS_DB.CULTIVATION.LEVEL9_INVENTORY a
set productid = cast(name as String)
FROM (select distinct name,id from (select name,id from FIVETRAN_DB.BT_JOLIET_PUBLIC.PRODUCTS UNION select name,id from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.PRODUCTS UNION select name,id from FIVETRAN_DB.BT_LINCOLN_PUBLIC.PRODUCTS) k ) g
where TRIM(a.productid) = g.id;

select * from ANALYTICS_DB.CULTIVATION.LEVEL_FINAL where SAMPLE_ID = '1905620673291412';


select * from ANALYTICS_DB.CULTIVATION.LEVEL_FINAL where INVENTORY_ID = '6151163706369023';

4587460732042893,7258403283195762,2465153758415644

select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY where id = '6151163706369023'

select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY where id = '9533010276589045'
4587460732042893,7258403283195762,2465153758415644
select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY where id = '2465153758415644' -- 7258403283195762
select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY where id = '4587460732042893' -- 2410028486412434
select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY where id = '7258403283195762' -- 7979403759845839

select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY where id = '7258403283195762' -- 7979403759845839
select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY where id = '2410028486412434' -- 9755508140362477
select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY where id = '7979403759845839' -- NULL


select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY where id = '7979403759845839' -- 7979403759845839
select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY where INVENTORYPARENTID = '9755508140362477'
select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY where id = '9755508140362477' -- 9755508140362477

select * from ANALYTICS_DB.CULTIVATION.LEVEL1_INVENTORY where INVENTORY_ID = ''
















Create or replace table ANALYTICS_DB.CULTIVATION.LEVEL1_INVENTORY as
select PLANTID, INVENTORY_ID,parentid,PLANT_ID_Original,weight, REMAININGWEIGHT, TRANSFERREDOUT, TRANSFERREDOUTTIME, f.Strain, inventorytype,SessionDate, dd.PLACEMENTGROUP, dd.ROOM_NBR_TAB as Room_Number, dd.ROOM_FRONT_BACK, k.roomname, f.LOC from
    (select PLANTID, INVENTORY_ID, PARENTID, trim(f.value, '"') as PLANT_ID_Original,weight, REMAININGWEIGHT, TRANSFERREDOUT, TRANSFERREDOUTTIME, Strain, inventorytype, cast(SessionDate as Date) as SessionDate, CURRENTROOM, LOC
     from
         (select  cast(SPLIT(cast(plantid as varchar), ',') as ARRAY) as PLANTID, id as inventory_id, PARENTID, INVENTORYPARENTID,Weight, REMAININGWEIGHT, TRANSFERREDOUT, TRANSFERREDOUTTIME, Strain, to_timestamp(SESSIONTIME) as SessionDate, inventorytype, CURRENTROOM, 'JOL' as LOC
          from
              FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
          where plantid is not null
          UNION
          select  cast(SPLIT(cast(plantid as varchar), ',') as ARRAY) as PLANTID, id as inventory_id, PARENTID, INVENTORYPARENTID,Weight, REMAININGWEIGHT, TRANSFERREDOUT, TRANSFERREDOUTTIME, Strain, to_timestamp(SESSIONTIME) as SessionDate, inventorytype, CURRENTROOM, 'KKE' as LOC
          from
              FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
          where plantid is not null
          UNION
          select  cast(SPLIT(cast(plantid as varchar), ',') as ARRAY) as PLANTID, id as inventory_id, PARENTID, INVENTORYPARENTID,Weight, REMAININGWEIGHT, TRANSFERREDOUT, TRANSFERREDOUTTIME, Strain, to_timestamp(SESSIONTIME) as SessionDate, inventorytype, CURRENTROOM, 'LNL' as LOC
          from
              FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY
          where plantid is not null



         ) ly, table(flatten(ly.PLANTID)) f) f
        left join ANALYTICS_DB.CULTIVATION.PLANT_PLACEMENT_GROUPS dd
                  on PLANT_ID_Original = dd.PLANT_ID
                    and case when f.loc = 'LNL' THEN 'Lincoln' WHEN f.loc = 'JOL' THEN 'Joliet' WHEN f.loc = 'KKE' then 'Kankakee' ELSE 'NONE' END = dd.location
        left join (select *, 'JOL' as LOC from  FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORYROOMS UNION select *, 'LNL' as LOC from  FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORYROOMS UNION select *, 'KKE' as LOC from  FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORYROOMS) k
                  on CURRENTROOM = k.id
                    and f.loc = k.loc

;

select * from ANALYTICS_DB.CULTIVATION.LEVEL1_INVENTORY



Create or replace table ANALYTICS_DB.CULTIVATION.LEVEL1_1_INVENTORY as
select g.id as inventory_id, g.id as OriginatingInvID,g.weight,g.SAMPLE_ID, g.REMAININGWEIGHT, g.TRANSFERREDOUT, g.TRANSFERREDOUTTIME, g.Strain, g.inventorytype, cast(to_timestamp(g.Sessiontime) as Date) as SessionDate, max(f.placementgroup) as placementgroup, max(Room_Number) as Room_number, max(room_front_back) as room_front_back, max(k.roomname) as InventoryRoom_Name, CONCAT(' ',cast(g.productid as string), ' ') as PRODUCTID, g.QUANTITY, g.LASTACTION,min(fh.Quantity) as Converted_Final_weiht2, max(fh.QUANTITY) as Converted_Final_Weight, fh.WASTE, min(fh.PARENT_QUANTITY_OLD) as Start_Quantity, max(fh.PARENT_QUANTITY_OLD) as end_quantity, min(INVENTORYID) as ConversionID, g.deleted, g.loc, LEFT(to_timestamp(g.created),10) as Created_Dt


from (select *, 'JOL' as LOC
      from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
      UNION
      select * , 'LNL' as LOC
      from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY
      UNION
      select *, 'KKE' as LOC
      from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
     )

    g
left join ANALYTICS_DB.CULTIVATION.LEVEL1_INVENTORY f
on f.inventory_id = coalesce(g.INVENTORYPARENTID, g.id)
    and f.loc = g.loc



left join (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORYCONVERSIONS_WA
    UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORYCONVERSIONS_WA
    UNION
    select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORYCONVERSIONS_WA
    ) fh on
       CASE WHEN fh.parentid like '%,%' THEN
        array_contains(g.id::variant, SPLIT(fh.parentid,',' )) = True
        ELSE g.id = fh.parentid end

left join (select *, 'JOL' as LOC from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORYROOMS UNION select *, 'KKE' as LOC from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORYROOMS UNION select *, 'LNL' as LOC from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORYROOMS) k
on g.CURRENTROOM = k.id
and g.LOC = k.LOC

where f.inventory_id is not null /*and g.INVENTORYTYPE in (12,13,14,6,9)*/
group by g.id , g.id ,g.weight,g.SAMPLE_ID, g.REMAININGWEIGHT, g.TRANSFERREDOUT, g.TRANSFERREDOUTTIME, g.Strain, g.inventorytype, cast(to_timestamp(g.Sessiontime) as Date),  CONCAT(' ',cast(g.productid as string), ' '), g.QUANTITY,  g.LASTACTION,  fh.WASTE, g.deleted, g.LOC, LEFT(to_timestamp(g.created),10);


select * from LEVEL1_1_INVENTORY where inventory_id = '7258403283195762'

select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY where INVENTORYPARENTID = '7258403283195762'