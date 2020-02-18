select b.roomname, a.*
from FIVETRAN_DB.BT_ENCANTO_PUBLIC.INVENTORY a
         left join FIVETRAN_DB.BT_ENCANTO_PUBLIC.INVENTORYROOMS b on a.CURRENTROOM = b.id
where plantid is not null
  and CREATED >= '2019-01-01';





create or replace table ANALYTICS_DB.CULTIVATION.INVENTORY_E
as select CAST(PLANTID as STRING) as plantid, INVENTORY_ID, trim(f.value, '"') as PLANT_ID_Original
      from (select cast(SPLIT(cast(plantid as varchar), ',') as ARRAY) as PLANTID, id as inventory_id
            from FIVETRAN_DB.BT_ENCANTO_PUBLIC.INVENTORY
            where plantid is not null
              and location in (3)
              and created >= '2019-01-01'
           ) ly,
           table (flatten(ly.PLANTID)) f;


alter table ANALYTICS_DB.CULTIVATION.INVENTORY_E
cluster by (plantid, INVENTORY_ID);

Create or replace table ANALYTICS_DB.CULTIVATION.LEVEL1_INVENTORY_E as
select PLANTID, INVENTORY_ID, PLANT_ID_Original, max(dd.PLACEMENTGROUP) as placementgroup, max(dd.ROOM_NBR_TAB) as Room_Number, max(dd.ROOM_FRONT_BACK) as ROOM_FRONT_BACK
from (ANALYTICS_DB.CULTIVATION.INVENTORY_E
    ) f
         left join (select *
                    from ANALYTICS_DB.CULTIVATION.PLANT_PLACEMENT_GROUPS
                    where LOCATION in ('Vicksburg','Encanto')) dd
                   on PLANT_ID_Original = dd.PLANT_ID

GROUP BY PLANTID, INVENTORY_ID, PLANT_ID_Original

;


Create or replace table ANALYTICS_DB.CULTIVATION.LEVEL1_1_INVENTORY_E as
select g.id as inventory_id, g.id as OriginatingInvID,g.weight,g.SAMPLE_ID, g.REMAININGWEIGHT, g.TRANSFERREDOUT, g.TRANSFERREDOUTTIME, g.Strain, g.inventorytype, cast(to_timestamp(g.Sessiontime) as Date) as SessionDate, max(f.placementgroup) as placementgroup, max(Room_Number) as Room_number, max(room_front_back) as room_front_back, max(k.roomname) as InventoryRoom_Name, CONCAT(' ',cast(g.productid as string), ' ') as PRODUCTID, g.QUANTITY, g.LASTACTION,min(fh.Quantity) as Converted_Final_weiht2, max(fh.QUANTITY) as Converted_Final_Weight, fh.WASTE, min(fh.PARENT_QUANTITY_OLD) as Start_Quantity, max(fh.PARENT_QUANTITY_OLD) as end_quantity, min(INVENTORYID) as ConversionID, g.deleted, g.loc, LEFT(to_timestamp(g.created),10) as Created_Dt


from (select *, 'AZ' as LOC
      from FIVETRAN_DB.BT_ENCANTO_PUBLIC.INVENTORY
     )

    g
left join ANALYTICS_DB.CULTIVATION.LEVEL1_INVENTORY_E f
on  f.inventory_id = g.INVENTORYPARENTID

left join (select * from    (select *, trim(f.value, '"') as parentid_Join3
   from

 (select  cast(SPLIT(cast(id as varchar), ',') as ARRAY) as parentid_join, childid as inventoryid,waste, newweight as quantity, OLDWEIGHT as PARENT_QUANTITY_OLD
 from
FIVETRAN_DB.BT_ENCANTO_PUBLIC.INVENTORYCONVERSIONS
     ) ly, table(flatten(ly.parentid_join)) f) f
) fh on
 g.id = fh.parentid_Join3


left join (select * from FIVETRAN_DB.BT_ENCANTO_PUBLIC.INVENTORYROOMS) k
on g.CURRENTROOM = k.id


where f.inventory_id is not null
group by g.id , g.id ,g.weight,g.SAMPLE_ID, g.REMAININGWEIGHT, g.TRANSFERREDOUT, g.TRANSFERREDOUTTIME, g.Strain, g.inventorytype, cast(to_timestamp(g.Sessiontime) as Date),  CONCAT(' ',cast(g.productid as string), ' '), g.QUANTITY,  g.LASTACTION,  fh.WASTE, g.deleted, g.LOC, LEFT(to_timestamp(g.created),10);


alter table ANALYTICS_DB.CULTIVATION.LEVEL1_1_INVENTORY_E
add column batchno string;

update ANALYTICS_DB.CULTIVATION.LEVEL1_1_INVENTORY_E a
set a.batchno = b.batchno
from (select * from FIVETRAN_DB.BT_ENCANTO_PUBLIC.INVENTORY
) b
where a.inventory_id = b.id;

alter table ANALYTICS_DB.CULTIVATION.LEVEL1_1_INVENTORY_E
add column inventorystatus string;

update ANALYTICS_DB.CULTIVATION.LEVEL1_1_INVENTORY_E a
set a.inventorystatus = b.inventorystatus
from (select * from FIVETRAN_DB.BT_ENCANTO_PUBLIC.INVENTORY
) b
where a.inventory_id = b.id;


alter table ANALYTICS_DB.CULTIVATION.LEVEL1_1_INVENTORY_E
add column packageweight string;

update ANALYTICS_DB.CULTIVATION.LEVEL1_1_INVENTORY_E a
set a.packageweight = b.packageweight
from (select * from FIVETRAN_DB.BT_ENCANTO_PUBLIC.INVENTORY
) b
where a.inventory_id = b.id;

alter table ANALYTICS_DB.CULTIVATION.LEVEL1_1_INVENTORY_E
add column RoomType string;

update ANALYTICS_DB.CULTIVATION.LEVEL1_1_INVENTORY_E
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

alter table ANALYTICS_DB.CULTIVATION.LEVEL1_1_INVENTORY_E
add column TestResults1 string;



update ANALYTICS_DB.CULTIVATION.LEVEL1_1_INVENTORY_E a
set TestResults1 = case when result = 1 THEN 'Passed' WHEN result = -1 then 'Failed' else 'No Test Results Yet' end
FROM (select parentid as sample_id, inventoryid, result from FIVETRAN_DB.BT_JOLIET_PUBLIC.BMSI_LABRESULTS_SAMPLES) g
where a.sample_id = g.inventoryid;




update ANALYTICS_DB.CULTIVATION.LEVEL1_1_INVENTORY_E a
set productid = cast(name as String)
FROM (select distinct name,id from (select name,id from FIVETRAN_DB.BT_ENCANTO_PUBLIC.PRODUCTS ) k ) g
where TRIM(a.productid) = g.id;





Create or replace table ANALYTICS_DB.CULTIVATION.LEVEL2_INVENTORY_E as
select g.id as inventory_id, f.OriginatingInvID as OriginatingInvID,g.weight,g.SAMPLE_ID, g.REMAININGWEIGHT, g.TRANSFERREDOUT, g.TRANSFERREDOUTTIME, g.Strain, g.inventorytype, cast(to_timestamp(g.Sessiontime) as Date) as SessionDate, max(f.placementgroup) as placementgroup, max(Room_Number) as Room_number, max(room_front_back) as room_front_back, max(k.roomname) as InventoryRoom_Name, CONCAT(' ',cast(g.productid as string), ' ') as PRODUCTID, g.QUANTITY, g.LASTACTION,min(fh.Quantity) as Converted_Final_weiht2, max(fh.QUANTITY) as Converted_Final_Weight, fh.WASTE, min(fh.PARENT_QUANTITY_OLD) as Start_Quantity, max(fh.PARENT_QUANTITY_OLD) as end_quantity, min(INVENTORYID) as ConversionID, g.deleted, g.loc, LEFT(to_timestamp(g.created),10) as Created_Dt from (select *, 'AZ' as LOC
      from FIVETRAN_DB.BT_ENCANTO_PUBLIC.INVENTORY

     ) g

left join ANALYTICS_DB.CULTIVATION.LEVEL1_1_INVENTORY_E f

on case when g.parentid like '%,%' THEN coalesce(array_contains(f.inventory_id::variant, split(g.parentid, ',' )) = True, array_contains(f.conversionid::variant, split(g.id, ',' )) = True) ELSE f.inventory_id = g.parentid END
left join (select * from    (select *, trim(f.value, '"') as parentid_Join3
   from

 (select  cast(SPLIT(cast(id as varchar), ',') as ARRAY) as parentid_join, *, newweight as quantity, OLDWEIGHT as PARENT_QUANTITY_OLD
 from
FIVETRAN_DB.BT_ENCANTO_PUBLIC.INVENTORYCONVERSIONS
     ) ly, table(flatten(ly.parentid_join)) f) f
) fh on
 g.id = fh.parentid_Join3
left join (select * from FIVETRAN_DB.BT_ENCANTO_PUBLIC.INVENTORYROOMS ) k
on g.CURRENTROOM = k.id
where (f.inventory_id is not null or f.conversionid is not null)
and f.inventory_id <> g.id
group by g.id , f.OriginatingInvID ,g.weight,g.SAMPLE_ID, g.REMAININGWEIGHT, g.TRANSFERREDOUT, g.TRANSFERREDOUTTIME, g.Strain, g.inventorytype, cast(to_timestamp(g.Sessiontime) as Date),  CONCAT(' ',cast(g.productid as string), ' '), g.QUANTITY,  g.LASTACTION,  fh.WASTE, g.deleted, g.loc, LEFT(to_timestamp(g.created),10);

alter table ANALYTICS_DB.CULTIVATION.LEVEL2_INVENTORY_E
add column batchno string;

update ANALYTICS_DB.CULTIVATION.LEVEL2_INVENTORY_E a
set a.batchno = b.batchno
from (select * from FIVETRAN_DB.BT_ENCANTO_PUBLIC.INVENTORY
) b
where a.inventory_id = b.id;

alter table ANALYTICS_DB.CULTIVATION.LEVEL2_INVENTORY_E
add column inventorystatus string;

update ANALYTICS_DB.CULTIVATION.LEVEL2_INVENTORY_E a
set a.inventorystatus = b.inventorystatus
from (select * from FIVETRAN_DB.BT_ENCANTO_PUBLIC.INVENTORY
) b
where a.inventory_id = b.id;


alter table ANALYTICS_DB.CULTIVATION.LEVEL2_INVENTORY_E
add column packageweight string;

update ANALYTICS_DB.CULTIVATION.LEVEL2_INVENTORY_E a
set a.packageweight = b.packageweight
from (select * from FIVETRAN_DB.BT_ENCANTO_PUBLIC.INVENTORY
) b
where a.inventory_id = b.id;

alter table ANALYTICS_DB.CULTIVATION.LEVEL2_INVENTORY_E
add column RoomType string;

update ANALYTICS_DB.CULTIVATION.LEVEL2_INVENTORY_E
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

alter table ANALYTICS_DB.CULTIVATION.LEVEL2_INVENTORY_E
add column TestResults1 string;



update ANALYTICS_DB.CULTIVATION.LEVEL2_INVENTORY_E a
set TestResults1 = case when result = 1 THEN 'Passed' WHEN result = -1 then 'Failed' else 'No Test Results Yet' end
FROM (select parentid as sample_id, inventoryid, result from FIVETRAN_DB.BT_JOLIET_PUBLIC.BMSI_LABRESULTS_SAMPLES) g
where a.sample_id = g.inventoryid;




update ANALYTICS_DB.CULTIVATION.LEVEL2_INVENTORY_E a
set productid = cast(name as String)
FROM (select distinct name,id from (select name,id from FIVETRAN_DB.BT_ENCANTO_PUBLIC.PRODUCTS ) k ) g
where TRIM(a.productid) = g.id;


select distinct OriginatingInvID, weight, REMAININGWEIGHT, strain, inventorytype, SessionDate, InventoryRoom_Name, Room_number, PRODUCTID, LASTACTION from (select *, 'Level1' as level from ANALYTICS_DB.CULTIVATION.LEVEL1_1_INVENTORY_E UNION
                select *, 'Level2' as level from ANALYTICS_DB.CULTIVATION.LEVEL2_INVENTORY_E) where REMAININGWEIGHT > 1 and TRANSFERREDOUT = 0 and inventorytype = 6 and deleted = 0



select * from ANALYTICS_DB.CULTIVATION.PLANT_YIELDS where strain = 'Blue Dream' and HARVEST_DATE_MAX >= '2019-11-01' and LOCATION = 'Vicksburg'


