
Create or replace table ANALYTICS_DB.CULTIVATION.LEVEL1_INVENTORY as
select PLANTID, INVENTORY_ID,parentid,PLANT_ID_Original,weight, REMAININGWEIGHT, TRANSFERREDOUT, TRANSFERREDOUTTIME, f.Strain, inventorytype,SessionDate, dd.PLACEMENTGROUP, dd.ROOM_NBR_TAB as Room_Number, dd.ROOM_FRONT_BACK, k.roomname from
    (select PLANTID, INVENTORY_ID, PARENTID, trim(f.value, '"') as PLANT_ID_Original,weight, REMAININGWEIGHT, TRANSFERREDOUT, TRANSFERREDOUTTIME, Strain, inventorytype, cast(SessionDate as Date) as SessionDate, CURRENTROOM
   from
 (select  cast(SPLIT(cast(plantid as varchar), ',') as ARRAY) as PLANTID, id as inventory_id, PARENTID, INVENTORYPARENTID,Weight, REMAININGWEIGHT, TRANSFERREDOUT, TRANSFERREDOUTTIME, Strain, to_timestamp(SESSIONTIME) as SessionDate, inventorytype, CURRENTROOM
 from
FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
where plantid is not null
     UNION
 select  cast(SPLIT(cast(plantid as varchar), ',') as ARRAY) as PLANTID, id as inventory_id, PARENTID, INVENTORYPARENTID,Weight, REMAININGWEIGHT, TRANSFERREDOUT, TRANSFERREDOUTTIME, Strain, to_timestamp(SESSIONTIME) as SessionDate, inventorytype, CURRENTROOM
 from
FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
where plantid is not null
     UNION
select  cast(SPLIT(cast(plantid as varchar), ',') as ARRAY) as PLANTID, id as inventory_id, PARENTID, INVENTORYPARENTID,Weight, REMAININGWEIGHT, TRANSFERREDOUT, TRANSFERREDOUTTIME, Strain, to_timestamp(SESSIONTIME) as SessionDate, inventorytype, CURRENTROOM
 from
FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY
where plantid is not null



     ) ly, table(flatten(ly.PLANTID)) f) f
left join ANALYTICS_DB.CULTIVATION.PLANT_PLACEMENT_GROUPS dd
on PLANT_ID_Original = dd.PLANT_ID
left join FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORYROOMS k
on CURRENTROOM = k.id

;


Create or replace table ANALYTICS_DB.CULTIVATION.LEVEL1_1_INVENTORY as
select g.id as inventory_id, g.id as OriginatingInvID,g.weight,g.SAMPLE_ID, g.REMAININGWEIGHT, g.TRANSFERREDOUT, g.TRANSFERREDOUTTIME, g.Strain, g.inventorytype, cast(to_timestamp(g.Sessiontime) as Date) as SessionDate, max(f.placementgroup) as placementgroup, max(Room_Number) as Room_number, max(room_front_back) as room_front_back, max(k.roomname) as InventoryRoom_Name, CONCAT(' ',cast(g.productid as string), ' ') as PRODUCTID, g.QUANTITY, g.LASTACTION,min(fh.Quantity) as Converted_Final_weiht2, max(fh.QUANTITY) as Converted_Final_Weight, fh.WASTE, min(fh.PARENT_QUANTITY_OLD) as Start_Quantity, max(fh.PARENT_QUANTITY_OLD) as end_quantity, min(INVENTORYID) as ConversionID, g.deleted, g.loc


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

where f.inventory_id is not null and g.INVENTORYTYPE in (12,13,14,6,9)
group by g.id , g.id ,g.weight,g.SAMPLE_ID, g.REMAININGWEIGHT, g.TRANSFERREDOUT, g.TRANSFERREDOUTTIME, g.Strain, g.inventorytype, cast(to_timestamp(g.Sessiontime) as Date),  CONCAT(' ',cast(g.productid as string), ' '), g.QUANTITY,  g.LASTACTION,  fh.WASTE, g.deleted, g.LOC;


alter table ANALYTICS_DB.CULTIVATION.LEVEL1_1_INVENTORY
add column batchno string;

update ANALYTICS_DB.CULTIVATION.LEVEL1_1_INVENTORY a
set a.batchno = b.batchno
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;

alter table ANALYTICS_DB.CULTIVATION.LEVEL1_1_INVENTORY
add column inventorystatus string;

update ANALYTICS_DB.CULTIVATION.LEVEL1_1_INVENTORY a
set a.inventorystatus = b.inventorystatus
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;


alter table ANALYTICS_DB.CULTIVATION.LEVEL1_1_INVENTORY
add column packageweight string;

update ANALYTICS_DB.CULTIVATION.LEVEL1_1_INVENTORY a
set a.packageweight = b.packageweight
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;



alter table ANALYTICS_DB.CULTIVATION.LEVEL1_1_INVENTORY
add column RoomType string;

update ANALYTICS_DB.CULTIVATION.LEVEL1_1_INVENTORY
set roomtype = case when InventoryRoom_Name like '%Cure Room%' THEN 'Dry Flower Lot'
when InventoryRoom_Name like '%Waste%' THEN 'Waste Lot'
when InventoryRoom_Name like '%Freeze%' THEN 'Fresh Frozen Lot'
when InventoryRoom_Name like '%BHO%' THEN 'BHO Lot'
when InventoryRoom_Name like '%CO2%' THEN 'CO2 Lot'
when InventoryRoom_Name like '%Ethanol%' THEN 'Ethanol Lot'
when InventoryRoom_Name like '%Extraction%' and InventoryRoom_Name like '%Vault%' THEN 'Extraction Lot'
when InventoryRoom_Name like '%Roman%' and InventoryRoom_Name like '%Vault%' THEN 'Roman Candle Lot'
when InventoryRoom_Name like '%Testing%' and InventoryRoom_Name like '%Vault%' THEN 'Tested Lot'
when InventoryRoom_Name like '%Working%' and InventoryRoom_Name like '%Flower Vault%' THEN 'Dry Flower Lot'
    ELSE NULL END;

alter table ANALYTICS_DB.CULTIVATION.LEVEL1_1_INVENTORY
add column TestResults1 string;



update ANALYTICS_DB.CULTIVATION.LEVEL1_1_INVENTORY a
set TestResults1 = case when result = 1 THEN 'Passed' WHEN result = -1 then 'Failed' else 'No Test Results Yet' end
FROM (select parentid as sample_id, inventoryid, result from FIVETRAN_DB.BT_JOLIET_PUBLIC.BMSI_LABRESULTS_SAMPLES) g
where a.sample_id = g.inventoryid;




update ANALYTICS_DB.CULTIVATION.LEVEL1_1_INVENTORY a
set productid = cast(name as String)
FROM (select distinct name,id from (select name,id from FIVETRAN_DB.BT_JOLIET_PUBLIC.PRODUCTS UNION select name,id from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.PRODUCTS UNION select name,id from FIVETRAN_DB.BT_LINCOLN_PUBLIC.PRODUCTS) k ) g
where TRIM(a.productid) = g.id;





Create or replace table ANALYTICS_DB.CULTIVATION.LEVEL2_INVENTORY as
select g.id as inventory_id, f.OriginatingInvID as OriginatingInvID,g.weight,g.SAMPLE_ID, g.REMAININGWEIGHT, g.TRANSFERREDOUT, g.TRANSFERREDOUTTIME, g.Strain, g.inventorytype, cast(to_timestamp(g.Sessiontime) as Date) as SessionDate, max(f.placementgroup) as placementgroup, max(Room_Number) as Room_number, max(room_front_back) as room_front_back, max(k.roomname) as InventoryRoom_Name, CONCAT(' ',cast(g.productid as string), ' ') as PRODUCTID, g.QUANTITY, g.LASTACTION,min(fh.Quantity) as Converted_Final_weiht2, max(fh.QUANTITY) as Converted_Final_Weight, fh.WASTE, min(fh.PARENT_QUANTITY_OLD) as Start_Quantity, max(fh.PARENT_QUANTITY_OLD) as end_quantity, min(INVENTORYID) as ConversionID, g.deleted, g.loc from (select *, 'JOL' as LOC
      from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
      UNION
      select * , 'LNL' as LOC
      from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY
      UNION
      select *, 'KKE' as LOC
      from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
     ) g

left join ANALYTICS_DB.CULTIVATION.LEVEL1_1_INVENTORY f

on case when g.parentid like '%,%' THEN coalesce(array_contains(f.inventory_id::variant, split(g.parentid, ',' )) = True, array_contains(f.conversionid::variant, split(g.id, ',' )) = True) ELSE f.inventory_id = g.parentid END
left join (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORYCONVERSIONS_WA) fh on  CASE WHEN fh.parentid like '%,%' THEN
        array_contains(g.id::variant, SPLIT(fh.parentid,',' )) = True
        ELSE g.id = fh.parentid end
left join (select *, 'JOL' as LOC from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORYROOMS UNION select *, 'KKE' as LOC from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORYROOMS UNION select *, 'LNL' as LOC from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORYROOMS) k
on g.CURRENTROOM = k.id
and g.LOC = k.LOC
where (f.inventory_id is not null or f.conversionid is not null)
and f.inventory_id <> g.id
group by g.id , f.OriginatingInvID ,g.weight,g.SAMPLE_ID, g.REMAININGWEIGHT, g.TRANSFERREDOUT, g.TRANSFERREDOUTTIME, g.Strain, g.inventorytype, cast(to_timestamp(g.Sessiontime) as Date),  CONCAT(' ',cast(g.productid as string), ' '), g.QUANTITY,  g.LASTACTION,  fh.WASTE, g.deleted, g.loc;

alter table ANALYTICS_DB.CULTIVATION.LEVEL2_INVENTORY
add column batchno string;

update ANALYTICS_DB.CULTIVATION.LEVEL2_INVENTORY a
set a.batchno = b.batchno
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;

alter table ANALYTICS_DB.CULTIVATION.LEVEL2_INVENTORY
add column inventorystatus string;

update ANALYTICS_DB.CULTIVATION.LEVEL2_INVENTORY a
set a.inventorystatus = b.inventorystatus
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;


alter table ANALYTICS_DB.CULTIVATION.LEVEL2_INVENTORY
add column packageweight string;

update ANALYTICS_DB.CULTIVATION.LEVEL2_INVENTORY a
set a.packageweight = b.packageweight
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;

alter table ANALYTICS_DB.CULTIVATION.LEVEL2_INVENTORY
add column RoomType string;

update ANALYTICS_DB.CULTIVATION.LEVEL2_INVENTORY
set roomtype = case when InventoryRoom_Name like '%Cure Room%' THEN 'Dry Flower Lot'
when InventoryRoom_Name like '%Waste%' THEN 'Waste Lot'
when InventoryRoom_Name like '%Freeze%' THEN 'Fresh Frozen Lot'
when InventoryRoom_Name like '%BHO%' THEN 'BHO Lot'
when InventoryRoom_Name like '%CO2%' THEN 'CO2 Lot'
when InventoryRoom_Name like '%Ethanol%' THEN 'Ethanol Lot'
when InventoryRoom_Name like '%Extraction%' and InventoryRoom_Name like '%Vault%' THEN 'Extraction Lot'
when InventoryRoom_Name like '%Roman%' and InventoryRoom_Name like '%Vault%' THEN 'Roman Candle Lot'
when InventoryRoom_Name like '%Testing%' and InventoryRoom_Name like '%Vault%' THEN 'Tested Lot'
when InventoryRoom_Name like '%Working%' and InventoryRoom_Name like '%Flower Vault%' THEN 'Dry Flower Lot'
    ELSE NULL END;

alter table ANALYTICS_DB.CULTIVATION.LEVEL2_INVENTORY
add column TestResults1 string;



update ANALYTICS_DB.CULTIVATION.LEVEL2_INVENTORY a
set TestResults1 = case when result = 1 THEN 'Passed' WHEN result = -1 then 'Failed' else 'No Test Results Yet' end
FROM (select parentid as sample_id, inventoryid, result from FIVETRAN_DB.BT_JOLIET_PUBLIC.BMSI_LABRESULTS_SAMPLES) g
where a.sample_id = g.inventoryid;




update ANALYTICS_DB.CULTIVATION.LEVEL2_INVENTORY a
set productid = cast(name as String)
FROM (select distinct name,id from (select name,id from FIVETRAN_DB.BT_JOLIET_PUBLIC.PRODUCTS UNION select name,id from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.PRODUCTS UNION select name,id from FIVETRAN_DB.BT_LINCOLN_PUBLIC.PRODUCTS) k ) g
where TRIM(a.productid) = g.id;






Create or replace table ANALYTICS_DB.CULTIVATION.LEVEL3_INVENTORY as
select g.id as inventory_id, f.OriginatingInvID as OriginatingInvID,g.weight,g.SAMPLE_ID, g.REMAININGWEIGHT, g.TRANSFERREDOUT, g.TRANSFERREDOUTTIME, g.Strain, g.inventorytype, cast(to_timestamp(g.Sessiontime) as Date) as SessionDate, max(f.placementgroup) as placementgroup, max(Room_Number) as Room_number, max(room_front_back) as room_front_back, max(k.roomname) as InventoryRoom_Name, CONCAT(' ',cast(g.productid as string), ' ') as PRODUCTID, g.QUANTITY, g.LASTACTION,min(fh.Quantity) as Converted_Final_weiht2, max(fh.QUANTITY) as Converted_Final_Weight, fh.WASTE, min(fh.PARENT_QUANTITY_OLD) as Start_Quantity, max(fh.PARENT_QUANTITY_OLD) as end_quantity, min(INVENTORYID) as ConversionID, g.deleted, g.loc


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




left join ANALYTICS_DB.CULTIVATION.LEVEL2_INVENTORY f
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
group by g.id , f.OriginatingInvID ,g.weight,g.SAMPLE_ID, g.REMAININGWEIGHT, g.TRANSFERREDOUT, g.TRANSFERREDOUTTIME, g.Strain, g.inventorytype, cast(to_timestamp(g.Sessiontime) as Date),  CONCAT(' ',cast(g.productid as string), ' '), g.QUANTITY,  g.LASTACTION,  fh.WASTE, g.deleted, g.loc;





alter table ANALYTICS_DB.CULTIVATION.LEVEL3_INVENTORY
add column batchno string;

update ANALYTICS_DB.CULTIVATION.LEVEL3_INVENTORY a
set a.batchno = b.batchno
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;

alter table ANALYTICS_DB.CULTIVATION.LEVEL3_INVENTORY
add column inventorystatus string;

update ANALYTICS_DB.CULTIVATION.LEVEL3_INVENTORY a
set a.inventorystatus = b.inventorystatus
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;




alter table ANALYTICS_DB.CULTIVATION.LEVEL3_INVENTORY
add column packageweight string;

update ANALYTICS_DB.CULTIVATION.LEVEL3_INVENTORY a
set a.packageweight = b.packageweight
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;


alter table ANALYTICS_DB.CULTIVATION.LEVEL3_INVENTORY
add column RoomType string;

update ANALYTICS_DB.CULTIVATION.LEVEL3_INVENTORY
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

alter table ANALYTICS_DB.CULTIVATION.LEVEL3_INVENTORY
add column TestResults1 string;




update ANALYTICS_DB.CULTIVATION.LEVEL3_INVENTORY a
set TestResults1 = case when result = 1 THEN 'Passed' WHEN result = -1 then 'Failed' else 'No Test Results Yet' end
FROM (select parentid as sample_id, inventoryid, result from FIVETRAN_DB.BT_JOLIET_PUBLIC.BMSI_LABRESULTS_SAMPLES) g
where a.sample_id = g.inventoryid;

update ANALYTICS_DB.CULTIVATION.LEVEL3_INVENTORY a
set TestResults1 = case when result = 1 THEN 'Passed' WHEN result = -1 then 'Failed' else 'No Test Results Yet' end
FROM (select INVENTORYPARENTID as sample_id, inventoryid, result from FIVETRAN_DB.BT_JOLIET_PUBLIC.BMSI_LABRESULTS_SAMPLES) g
where a.sample_id = g.sample_id;



update ANALYTICS_DB.CULTIVATION.LEVEL3_INVENTORY a
set productid = cast(name as String)
FROM (select distinct name,id from (select name,id from FIVETRAN_DB.BT_JOLIET_PUBLIC.PRODUCTS UNION select name,id from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.PRODUCTS UNION select name,id from FIVETRAN_DB.BT_LINCOLN_PUBLIC.PRODUCTS) k ) g
where TRIM(a.productid) = g.id;





























----------TESTING NEW SHIT

Create or replace table ANALYTICS_DB.CULTIVATION.LEVEL4_INVENTORY as
select g.id as inventory_id, f.OriginatingInvID as OriginatingInvID,g.weight,g.SAMPLE_ID, g.REMAININGWEIGHT, g.TRANSFERREDOUT, g.TRANSFERREDOUTTIME, g.Strain, g.inventorytype, cast(to_timestamp(g.Sessiontime) as Date) as SessionDate, max(f.placementgroup) as placementgroup, max(Room_Number) as Room_number, max(room_front_back) as room_front_back, max(k.roomname) as InventoryRoom_Name, CONCAT(' ',cast(g.productid as string), ' ') as PRODUCTID, g.QUANTITY, g.LASTACTION,min(fh.Quantity) as Converted_Final_weiht2, max(fh.QUANTITY) as Converted_Final_Weight, fh.WASTE, min(fh.PARENT_QUANTITY_OLD) as Start_Quantity, max(fh.PARENT_QUANTITY_OLD) as end_quantity, min(INVENTORYID) as ConversionID, g.deleted, g.loc


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




left join ANALYTICS_DB.CULTIVATION.LEVEL3_INVENTORY f
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
group by g.id , f.OriginatingInvID ,g.weight,g.SAMPLE_ID, g.REMAININGWEIGHT, g.TRANSFERREDOUT, g.TRANSFERREDOUTTIME, g.Strain, g.inventorytype, cast(to_timestamp(g.Sessiontime) as Date),  CONCAT(' ',cast(g.productid as string), ' '), g.QUANTITY,  g.LASTACTION,  fh.WASTE, g.deleted, g.loc;

alter table ANALYTICS_DB.CULTIVATION.LEVEL4_INVENTORY
add column batchno string;

update ANALYTICS_DB.CULTIVATION.LEVEL4_INVENTORY a
set a.batchno = b.batchno
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;


alter table ANALYTICS_DB.CULTIVATION.LEVEL4_INVENTORY
add column inventorystatus string;

update ANALYTICS_DB.CULTIVATION.LEVEL4_INVENTORY a
set a.inventorystatus = b.inventorystatus
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;


alter table ANALYTICS_DB.CULTIVATION.LEVEL4_INVENTORY
add column packageweight string;

update ANALYTICS_DB.CULTIVATION.LEVEL4_INVENTORY a
set a.packageweight = b.packageweight
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;

alter table ANALYTICS_DB.CULTIVATION.LEVEL4_INVENTORY
add column RoomType string;

update ANALYTICS_DB.CULTIVATION.LEVEL4_INVENTORY
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

alter table ANALYTICS_DB.CULTIVATION.LEVEL4_INVENTORY
add column TestResults1 string;




update ANALYTICS_DB.CULTIVATION.LEVEL4_INVENTORY a
set TestResults1 = case when result = 1 THEN 'Passed' WHEN result = -1 then 'Failed' else 'No Test Results Yet' end
FROM (select id as sample_id, inventoryid, result from FIVETRAN_DB.BT_JOLIET_PUBLIC.BMSI_LABRESULTS_SAMPLES) g
where a.sample_id = g.inventoryid;


update ANALYTICS_DB.CULTIVATION.LEVEL4_INVENTORY a
set productid = cast(name as String)
FROM (select distinct name,id from (select name,id from FIVETRAN_DB.BT_JOLIET_PUBLIC.PRODUCTS UNION select name,id from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.PRODUCTS UNION select name,id from FIVETRAN_DB.BT_LINCOLN_PUBLIC.PRODUCTS) k ) g
where TRIM(a.productid) = g.id;

Create or replace table ANALYTICS_DB.CULTIVATION.LEVEL5_INVENTORY as
select g.id as inventory_id, f.OriginatingInvID as OriginatingInvID,g.weight,g.SAMPLE_ID, g.REMAININGWEIGHT, g.TRANSFERREDOUT, g.TRANSFERREDOUTTIME, g.Strain, g.inventorytype, cast(to_timestamp(g.Sessiontime) as Date) as SessionDate, max(f.placementgroup) as placementgroup, max(Room_Number) as Room_number, max(room_front_back) as room_front_back, max(k.roomname) as InventoryRoom_Name, CONCAT(' ',cast(g.productid as string), ' ') as PRODUCTID, g.QUANTITY, g.LASTACTION,min(fh.Quantity) as Converted_Final_weiht2, max(fh.QUANTITY) as Converted_Final_Weight, fh.WASTE, min(fh.PARENT_QUANTITY_OLD) as Start_Quantity, max(fh.PARENT_QUANTITY_OLD) as end_quantity, min(INVENTORYID) as ConversionID, g.deleted, g.loc


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




left join ANALYTICS_DB.CULTIVATION.LEVEL4_INVENTORY f
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
group by g.id , f.OriginatingInvID ,g.weight,g.SAMPLE_ID, g.REMAININGWEIGHT, g.TRANSFERREDOUT, g.TRANSFERREDOUTTIME, g.Strain, g.inventorytype, cast(to_timestamp(g.Sessiontime) as Date),  CONCAT(' ',cast(g.productid as string), ' '), g.QUANTITY,  g.LASTACTION,  fh.WASTE, g.deleted, g.loc;

alter table ANALYTICS_DB.CULTIVATION.LEVEL5_INVENTORY
add column batchno string;

update ANALYTICS_DB.CULTIVATION.LEVEL5_INVENTORY a
set a.batchno = b.batchno
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;


alter table ANALYTICS_DB.CULTIVATION.LEVEL5_INVENTORY
add column inventorystatus string;

update ANALYTICS_DB.CULTIVATION.LEVEL5_INVENTORY a
set a.inventorystatus = b.inventorystatus
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;




alter table ANALYTICS_DB.CULTIVATION.LEVEL5_INVENTORY
add column packageweight string;

update ANALYTICS_DB.CULTIVATION.LEVEL5_INVENTORY a
set a.packageweight = b.packageweight
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;


alter table ANALYTICS_DB.CULTIVATION.LEVEL5_INVENTORY
add column RoomType string;

update ANALYTICS_DB.CULTIVATION.LEVEL5_INVENTORY
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

alter table ANALYTICS_DB.CULTIVATION.LEVEL5_INVENTORY
add column TestResults1 string;




update ANALYTICS_DB.CULTIVATION.LEVEL5_INVENTORY a
set TestResults1 = case when result = 1 THEN 'Passed' WHEN result = -1 then 'Failed' else 'No Test Results Yet' end
FROM (select id as sample_id, inventoryid, result from FIVETRAN_DB.BT_JOLIET_PUBLIC.BMSI_LABRESULTS_SAMPLES) g
where a.sample_id = g.inventoryid;


update ANALYTICS_DB.CULTIVATION.LEVEL5_INVENTORY a
set productid = cast(name as String)
FROM (select distinct name,id from (select name,id from FIVETRAN_DB.BT_JOLIET_PUBLIC.PRODUCTS UNION select name,id from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.PRODUCTS UNION select name,id from FIVETRAN_DB.BT_LINCOLN_PUBLIC.PRODUCTS) k ) g
where TRIM(a.productid) = g.id;

Create or replace table ANALYTICS_DB.CULTIVATION.LEVEL6_INVENTORY as
select g.id as inventory_id, f.OriginatingInvID as OriginatingInvID,g.weight,g.SAMPLE_ID, g.REMAININGWEIGHT, g.TRANSFERREDOUT, g.TRANSFERREDOUTTIME, g.Strain, g.inventorytype, cast(to_timestamp(g.Sessiontime) as Date) as SessionDate, max(f.placementgroup) as placementgroup, max(Room_Number) as Room_number, max(room_front_back) as room_front_back, max(k.roomname) as InventoryRoom_Name, CONCAT(' ',cast(g.productid as string), ' ') as PRODUCTID, g.QUANTITY, g.LASTACTION,min(fh.Quantity) as Converted_Final_weiht2, max(fh.QUANTITY) as Converted_Final_Weight, fh.WASTE, min(fh.PARENT_QUANTITY_OLD) as Start_Quantity, max(fh.PARENT_QUANTITY_OLD) as end_quantity, min(INVENTORYID) as ConversionID, g.deleted, g.loc


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




left join ANALYTICS_DB.CULTIVATION.LEVEL5_INVENTORY f
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
group by g.id , f.OriginatingInvID ,g.weight,g.SAMPLE_ID, g.REMAININGWEIGHT, g.TRANSFERREDOUT, g.TRANSFERREDOUTTIME, g.Strain, g.inventorytype, cast(to_timestamp(g.Sessiontime) as Date),  CONCAT(' ',cast(g.productid as string), ' '), g.QUANTITY,  g.LASTACTION,  fh.WASTE, g.deleted, g.loc;


alter table ANALYTICS_DB.CULTIVATION.LEVEL6_INVENTORY
add column batchno string;

update ANALYTICS_DB.CULTIVATION.LEVEL6_INVENTORY a
set a.batchno = b.batchno
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;

alter table ANALYTICS_DB.CULTIVATION.LEVEL6_INVENTORY
add column inventorystatus string;

update ANALYTICS_DB.CULTIVATION.LEVEL6_INVENTORY a
set a.inventorystatus = b.inventorystatus
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;




alter table ANALYTICS_DB.CULTIVATION.LEVEL6_INVENTORY
add column packageweight string;

update ANALYTICS_DB.CULTIVATION.LEVEL6_INVENTORY a
set a.packageweight = b.packageweight
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;


alter table ANALYTICS_DB.CULTIVATION.LEVEL6_INVENTORY
add column RoomType string;

update ANALYTICS_DB.CULTIVATION.LEVEL6_INVENTORY
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

alter table ANALYTICS_DB.CULTIVATION.LEVEL6_INVENTORY
add column TestResults1 string;




update ANALYTICS_DB.CULTIVATION.LEVEL6_INVENTORY a
set TestResults1 = case when result = 1 THEN 'Passed' WHEN result = -1 then 'Failed' else 'No Test Results Yet' end
FROM (select id as sample_id, inventoryid, result from FIVETRAN_DB.BT_JOLIET_PUBLIC.BMSI_LABRESULTS_SAMPLES) g
where a.sample_id = g.inventoryid;


update ANALYTICS_DB.CULTIVATION.LEVEL6_INVENTORY a
set productid = cast(name as String)
FROM (select distinct name,id from (select name,id from FIVETRAN_DB.BT_JOLIET_PUBLIC.PRODUCTS UNION select name,id from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.PRODUCTS UNION select name,id from FIVETRAN_DB.BT_LINCOLN_PUBLIC.PRODUCTS) k ) g
where TRIM(a.productid) = g.id;




Create or replace table ANALYTICS_DB.CULTIVATION.LEVEL7_INVENTORY as
select g.id as inventory_id, f.OriginatingInvID as OriginatingInvID,g.weight,g.SAMPLE_ID, g.REMAININGWEIGHT, g.TRANSFERREDOUT, g.TRANSFERREDOUTTIME, g.Strain, g.inventorytype, cast(to_timestamp(g.Sessiontime) as Date) as SessionDate, max(f.placementgroup) as placementgroup, max(Room_Number) as Room_number, max(room_front_back) as room_front_back, max(k.roomname) as InventoryRoom_Name, CONCAT(' ',cast(g.productid as string), ' ') as PRODUCTID, g.QUANTITY, g.LASTACTION,min(fh.Quantity) as Converted_Final_weiht2, max(fh.QUANTITY) as Converted_Final_Weight, fh.WASTE, min(fh.PARENT_QUANTITY_OLD) as Start_Quantity, max(fh.PARENT_QUANTITY_OLD) as end_quantity, min(INVENTORYID) as ConversionID, g.deleted, g.loc


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




left join ANALYTICS_DB.CULTIVATION.LEVEL6_INVENTORY f
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
group by g.id , f.OriginatingInvID ,g.weight,g.SAMPLE_ID, g.REMAININGWEIGHT, g.TRANSFERREDOUT, g.TRANSFERREDOUTTIME, g.Strain, g.inventorytype, cast(to_timestamp(g.Sessiontime) as Date),  CONCAT(' ',cast(g.productid as string), ' '), g.QUANTITY,  g.LASTACTION,  fh.WASTE, g.deleted, g.loc;


alter table ANALYTICS_DB.CULTIVATION.LEVEL7_INVENTORY
add column batchno string;

update ANALYTICS_DB.CULTIVATION.LEVEL7_INVENTORY a
set a.batchno = b.batchno
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;

alter table ANALYTICS_DB.CULTIVATION.LEVEL7_INVENTORY
add column inventorystatus string;

update ANALYTICS_DB.CULTIVATION.LEVEL7_INVENTORY a
set a.inventorystatus = b.inventorystatus
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;




alter table ANALYTICS_DB.CULTIVATION.LEVEL7_INVENTORY
add column packageweight string;

update ANALYTICS_DB.CULTIVATION.LEVEL7_INVENTORY a
set a.packageweight = b.packageweight
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;


alter table ANALYTICS_DB.CULTIVATION.LEVEL7_INVENTORY
add column RoomType string;

update ANALYTICS_DB.CULTIVATION.LEVEL7_INVENTORY
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

alter table ANALYTICS_DB.CULTIVATION.LEVEL7_INVENTORY
add column TestResults1 string;




update ANALYTICS_DB.CULTIVATION.LEVEL7_INVENTORY a
set TestResults1 = case when result = 1 THEN 'Passed' WHEN result = -1 then 'Failed' else 'No Test Results Yet' end
FROM (select id as sample_id, inventoryid, result from FIVETRAN_DB.BT_JOLIET_PUBLIC.BMSI_LABRESULTS_SAMPLES) g
where a.sample_id = g.inventoryid;


update ANALYTICS_DB.CULTIVATION.LEVEL7_INVENTORY a
set productid = cast(name as String)
FROM (select distinct name,id from (select name,id from FIVETRAN_DB.BT_JOLIET_PUBLIC.PRODUCTS UNION select name,id from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.PRODUCTS UNION select name,id from FIVETRAN_DB.BT_LINCOLN_PUBLIC.PRODUCTS) k ) g
where TRIM(a.productid) = g.id;



Create or replace table ANALYTICS_DB.CULTIVATION.LEVEL8_INVENTORY as
select g.id as inventory_id, f.OriginatingInvID as OriginatingInvID,g.weight,g.SAMPLE_ID, g.REMAININGWEIGHT, g.TRANSFERREDOUT, g.TRANSFERREDOUTTIME, g.Strain, g.inventorytype, cast(to_timestamp(g.Sessiontime) as Date) as SessionDate, max(f.placementgroup) as placementgroup, max(Room_Number) as Room_number, max(room_front_back) as room_front_back, max(k.roomname) as InventoryRoom_Name, CONCAT(' ',cast(g.productid as string), ' ') as PRODUCTID, g.QUANTITY, g.LASTACTION,min(fh.Quantity) as Converted_Final_weiht2, max(fh.QUANTITY) as Converted_Final_Weight, fh.WASTE, min(fh.PARENT_QUANTITY_OLD) as Start_Quantity, max(fh.PARENT_QUANTITY_OLD) as end_quantity, min(INVENTORYID) as ConversionID, g.deleted, g.loc


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




left join ANALYTICS_DB.CULTIVATION.LEVEL7_INVENTORY f
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
group by g.id , f.OriginatingInvID ,g.weight,g.SAMPLE_ID, g.REMAININGWEIGHT, g.TRANSFERREDOUT, g.TRANSFERREDOUTTIME, g.Strain, g.inventorytype, cast(to_timestamp(g.Sessiontime) as Date),  CONCAT(' ',cast(g.productid as string), ' '), g.QUANTITY,  g.LASTACTION,  fh.WASTE, g.deleted, g.loc;


alter table ANALYTICS_DB.CULTIVATION.LEVEL8_INVENTORY
add column batchno string;

update ANALYTICS_DB.CULTIVATION.LEVEL8_INVENTORY a
set a.batchno = b.batchno
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;

alter table ANALYTICS_DB.CULTIVATION.LEVEL8_INVENTORY
add column inventorystatus string;

update ANALYTICS_DB.CULTIVATION.LEVEL8_INVENTORY a
set a.inventorystatus = b.inventorystatus
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;




alter table ANALYTICS_DB.CULTIVATION.LEVEL8_INVENTORY
add column packageweight string;

update ANALYTICS_DB.CULTIVATION.LEVEL8_INVENTORY a
set a.packageweight = b.packageweight
from (select * from FIVETRAN_DB.BT_JOLIET_PUBLIC.INVENTORY
UNION
    select * from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.INVENTORY
UNION
select * from FIVETRAN_DB.BT_LINCOLN_PUBLIC.INVENTORY) b
where a.inventory_id = b.id;


alter table ANALYTICS_DB.CULTIVATION.LEVEL8_INVENTORY
add column RoomType string;

update ANALYTICS_DB.CULTIVATION.LEVEL8_INVENTORY
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

alter table ANALYTICS_DB.CULTIVATION.LEVEL8_INVENTORY
add column TestResults1 string;




update ANALYTICS_DB.CULTIVATION.LEVEL8_INVENTORY a
set TestResults1 = case when result = 1 THEN 'Passed' WHEN result = -1 then 'Failed' else 'No Test Results Yet' end
FROM (select id as sample_id, inventoryid, result from FIVETRAN_DB.BT_JOLIET_PUBLIC.BMSI_LABRESULTS_SAMPLES) g
where a.sample_id = g.inventoryid;


update ANALYTICS_DB.CULTIVATION.LEVEL8_INVENTORY a
set productid = cast(name as String)
FROM (select distinct name,id from (select name,id from FIVETRAN_DB.BT_JOLIET_PUBLIC.PRODUCTS UNION select name,id from FIVETRAN_DB.BT_KANKAKEE_PUBLIC.PRODUCTS UNION select name,id from FIVETRAN_DB.BT_LINCOLN_PUBLIC.PRODUCTS) k ) g
where TRIM(a.productid) = g.id;

Create or replace table ANALYTICS_DB.CULTIVATION.LEVEL_FINAL as


    (select *, 'Level1' as Level from ANALYTICS_DB.CULTIVATION.LEVEL1_1_INVENTORY
UNION
select *, 'Level2' as Level from ANALYTICS_DB.CULTIVATION.LEVEL2_INVENTORY
UNION
select *, 'Level3' as level from ANALYTICS_DB.CULTIVATION.LEVEL3_INVENTORY
UNION
select *, 'Level4' as level from ANALYTICS_DB.CULTIVATION.LEVEL4_INVENTORY
UNION
select *, 'level5' as level from ANALYTICS_DB.CULTIVATION.LEVEL5_INVENTORY
UNION
select *, 'level6' as level from ANALYTICS_DB.CULTIVATION.LEVEL6_INVENTORY
UNION
select *, 'level7' as level from ANALYTICS_DB.CULTIVATION.LEVEL7_INVENTORY
UNION
select *, 'level8' as level from ANALYTICS_DB.CULTIVATION.LEVEL8_INVENTORY
    )

;


