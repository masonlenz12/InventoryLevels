

--drop table if exists ANALYTICS_DB.masonl.MITTO_EXPECTED_WEIGHTS_Temp;
create or replace table ANALYTICS_DB.masonl.MITTO_EXPECTED_WEIGHTS_Temp as
select
       PLACEMENT_NEW_TRACEABILITY as Traceability_Date,
       PLANT_PLACEMENT,
       PREDICTED_HARVEST_DATE,
       FACILITY,
       base.ROOM,
       base.STRAIN_TYPE,
       base.STRAIN,
       COUNT,
       base.CULTIVATION_ENVIRONMENT,
       coalesce(AVG_WET_WEIGHT_PER_PLANT, dwy.WET_WEIGHT_PER_PLANT)  AVG_WET_WEIGHT_PER_PLANT,
       coalesce(AVG_WET_FOR_DRY_WEIGHT, DWY.WET_FOR_DRY_WEIGHT) AVG_WET_FOR_DRY_WEIGHT,
       coalesce(AVG_PRE_DEBONED_FF_WEIGHT,PRE_DEBONED_FF_WEIGHT) AVG_PRE_DEBONED_FF_WEIGHT,
       coalesce(AVG_WET_FOR_DRY_RETENTION_WEIGHT,dwy.WET_FOR_DRY_RETENTION_WEIGHT ) AVG_WET_FOR_DRY_RETENTION_WEIGHT,
       coalesce(AVG_FF_PERC, dwy.FF_PERC) AVG_FF_PERC,
       coalesce(AVG_FF_DEBONED_RATE, dwy.FF_DEBONED_RATE) as  AVG_FF_DEBONED_RATE,
        mpa.EXTRACT_PERCENTAGE,
        mpa.KIEF_PERCENTAGE,
        mpa.POPCORN_PERCENTAGE,
        mpa.PREMIUM_PERCENTAGE,
        mpa.SHAKE_PERCENTAGE,
        mpa.WASTE_PERCENTAGE,
       COUNT * "Yield_Mod" * coalesce(AVG_WET_WEIGHT_PER_PLANT, dwy.WET_WEIGHT_PER_PLANT)                                         as Projected_Wet_Weight,
       COUNT * "Yield_Mod" * coalesce(AVG_WET_WEIGHT_PER_PLANT, dwy.WET_WEIGHT_PER_PLANT)   *
       coalesce(AVG_WET_FOR_DRY_RETENTION_WEIGHT,dwy.WET_FOR_DRY_RETENTION_WEIGHT )                                                     as Projected_Normalized_Dry_Weight,
       (COUNT * "Yield_Mod" * coalesce(AVG_WET_WEIGHT_PER_PLANT, dwy.WET_WEIGHT_PER_PLANT)  ) * coalesce(base.ff_modifier, 0)   * coalesce(AVG_FF_DEBONED_RATE, dwy.FF_DEBONED_RATE, .7) as Projected_FF_Weight,
       coalesce((COUNT * "Yield_Mod" * coalesce(AVG_WET_WEIGHT_PER_PLANT, dwy.WET_WEIGHT_PER_PLANT)  ), 0) -
       coalesce(((COUNT * "Yield_Mod" * coalesce(AVG_WET_WEIGHT_PER_PLANT, dwy.WET_WEIGHT_PER_PLANT)  ) * coalesce(AVG_FF_PERC, dwy.FF_PERC)), 0)           Projected_Wet_For_Dry,
       (coalesce((COUNT * "Yield_Mod" * coalesce(AVG_WET_WEIGHT_PER_PLANT, dwy.WET_WEIGHT_PER_PLANT)  ), 0) -
        coalesce(((COUNT * "Yield_Mod" * coalesce(AVG_WET_WEIGHT_PER_PLANT, dwy.WET_WEIGHT_PER_PLANT)  ) * coalesce(AVG_FF_PERC, dwy.FF_PERC)), 0)) *
       coalesce(AVG_WET_FOR_DRY_RETENTION_WEIGHT,dwy.WET_FOR_DRY_RETENTION_WEIGHT )                                                     as Projected_Dry_Weight,

       ((coalesce((COUNT * "Yield_Mod" * coalesce(AVG_WET_WEIGHT_PER_PLANT, dwy.WET_WEIGHT_PER_PLANT)  ), 0) -
         coalesce(((COUNT * "Yield_Mod" * coalesce(AVG_WET_WEIGHT_PER_PLANT, dwy.WET_WEIGHT_PER_PLANT)  ) * coalesce(AVG_FF_PERC, dwy.FF_PERC)), 0)) *
        coalesce(AVG_WET_FOR_DRY_RETENTION_WEIGHT,dwy.WET_FOR_DRY_RETENTION_WEIGHT )) * coalesce(mpa.EXTRACT_PERCENTAGE, dpp.EXTRACT_PERCENTAGE)                              as Extract_Weight,
       ((coalesce((COUNT * "Yield_Mod" * coalesce(AVG_WET_WEIGHT_PER_PLANT, dwy.WET_WEIGHT_PER_PLANT)  ), 0) -
         coalesce(((COUNT * "Yield_Mod" * coalesce(AVG_WET_WEIGHT_PER_PLANT, dwy.WET_WEIGHT_PER_PLANT)  ) * coalesce(AVG_FF_PERC, dwy.FF_PERC)), 0)) *
        coalesce(AVG_WET_FOR_DRY_RETENTION_WEIGHT,dwy.WET_FOR_DRY_RETENTION_WEIGHT )) * coalesce( mpa.KIEF_PERCENTAGE, dpp.KIEF_PERCENTAGE)                                 as Kief_Weight,
       ((coalesce((COUNT * "Yield_Mod" * coalesce(AVG_WET_WEIGHT_PER_PLANT, dwy.WET_WEIGHT_PER_PLANT)  ), 0) -
         coalesce(((COUNT * "Yield_Mod" * coalesce(AVG_WET_WEIGHT_PER_PLANT, dwy.WET_WEIGHT_PER_PLANT)  ) * coalesce(AVG_FF_PERC, dwy.FF_PERC)), 0)) *
        coalesce(AVG_WET_FOR_DRY_RETENTION_WEIGHT,dwy.WET_FOR_DRY_RETENTION_WEIGHT )) *  coalesce( mpa.POPCORN_PERCENTAGE, dpp.POPCORN_PERCENTAGE)                              as Popcorn_Weight,
       ((coalesce((COUNT * "Yield_Mod" * coalesce(AVG_WET_WEIGHT_PER_PLANT, dwy.WET_WEIGHT_PER_PLANT)  ), 0) -
         coalesce(((COUNT * "Yield_Mod" * coalesce(AVG_WET_WEIGHT_PER_PLANT, dwy.WET_WEIGHT_PER_PLANT)  ) * coalesce(AVG_FF_PERC, dwy.FF_PERC)), 0)) *
        coalesce(AVG_WET_FOR_DRY_RETENTION_WEIGHT,dwy.WET_FOR_DRY_RETENTION_WEIGHT )) *  coalesce( mpa.PREMIUM_PERCENTAGE, dpp.PREMIUM_PERCENTAGE)                              as Premium_Weight,
       ((coalesce((COUNT * "Yield_Mod" * coalesce(AVG_WET_WEIGHT_PER_PLANT, dwy.WET_WEIGHT_PER_PLANT)  ), 0) -
         coalesce(((COUNT * "Yield_Mod" * coalesce(AVG_WET_WEIGHT_PER_PLANT, dwy.WET_WEIGHT_PER_PLANT)  ) * coalesce(AVG_FF_PERC, dwy.FF_PERC)), 0)) *
        coalesce(AVG_WET_FOR_DRY_RETENTION_WEIGHT,dwy.WET_FOR_DRY_RETENTION_WEIGHT )) *  coalesce( mpa.SHAKE_PERCENTAGE, dpp.SHAKE_PERCENTAGE)                                as Shake_Weight,
       ((coalesce((COUNT * "Yield_Mod" * coalesce(AVG_WET_WEIGHT_PER_PLANT, dwy.WET_WEIGHT_PER_PLANT)  ), 0) -
         coalesce(((COUNT * "Yield_Mod" * coalesce(AVG_WET_WEIGHT_PER_PLANT, dwy.WET_WEIGHT_PER_PLANT)  ) * coalesce(AVG_FF_PERC, dwy.FF_PERC)), 0)) *
        coalesce(AVG_WET_FOR_DRY_RETENTION_WEIGHT,dwy.WET_FOR_DRY_RETENTION_WEIGHT )) *  coalesce( mpa.WASTE_PERCENTAGE, dpp.WASTE_PERCENTAGE)                                as Waste_Weight

from (
         select a.PLACEMENT_NEW_TRACEABILITY,
                a.PLANT_PLACEMENT,
                                            a.PREDICTED_HARVEST_DATE,
                                            a.FACILITY,
                a.CULTIVATION_ENVIRONMENT,
                                            a.ROOM,
                                            a.STRAIN_TYPE,
                                            a.STRAIN,
                                            a.COUNT,
                                            a."Yield_Mod",
         b.ff_modifier
         from DEMO_DB.PRODUCTION_PLAN.PLACEMENT_NEW_HISTORICAL a
    left join ANALYTICS_DB.masonl.placementnew b on a.PLANT_PLACEMENT = b.plant_placement and a.FACILITY = b.facility and a.room = b.room and a.STRAIN = b.strain

     ) base
         left join (select CULTIVATION_YIELDS_TRACEABILITY,
                           HARVEST_FACILITY,
                           CULTIVATION_ENVIRONMENT,
                           ROOM,
                           STRAIN_TYPE,
                           trim(STRAIN) as strain,
                           AVG_WET_WEIGHT_PER_PLANT,
                           AVG_WET_FOR_DRY_WEIGHT,
                           AVG_PRE_DEBONED_FF_WEIGHT,
                           AVG_WET_FOR_DRY_RETENTION_WEIGHT,
                           AVG_FF_PERC,
                           AVG_FF_DEBONED_RATE
                    from ANALYTICS_DB.CULTIVATION.MITTO_WEIGHT_AVERAGES_HISTORICAL) mwa
                   on base.PLACEMENT_NEW_TRACEABILITY=mwa.CULTIVATION_YIELDS_TRACEABILITY and base.FACILITY = mwa.HARVEST_FACILITY and base.ROOM = mwa.ROOM and base.STRAIN = mwa.STRAIN
         left join (select PROCESSING_TRACKER_TRACEABILITY,
                           HARVEST_FACILITY,
                           STRAIN_TYPE,
                           trim(STRAIN) as strain,
                           JOIN_TYPE,
                           EXTRACT_PERCENTAGE,
                           KIEF_PERCENTAGE,
                           POPCORN_PERCENTAGE,
                           PREMIUM_PERCENTAGE,
                           SHAKE_PERCENTAGE,
                           WASTE_PERCENTAGE
                    from ANALYTICS_DB.CULTIVATION.MITTO_PROCESSING_TRACKER_AVERAGES) mpa
                   on base.PLACEMENT_NEW_TRACEABILITY=mpa.PROCESSING_TRACKER_TRACEABILITY and base.FACILITY = mpa.HARVEST_FACILITY and base.STRAIN = mpa.STRAIN
left join ANALYTICS_DB.CULTIVATION.DEFAULT_PERCENTAGES_PROCESSING dpp
on 1=1
left join ANALYTICS_DB.CULTIVATION.DEFAULT_WEIGHTS_YIELD dwy
        on base.CULTIVATION_ENVIRONMENT=dwy.CULTIVATION_ENVIRONMENT and base.STRAIN_TYPE=dwy.STRAIN_TYPE
        where PLACEMENT_NEW_TRACEABILITY= (select max(PROCESSING_TRACKER_TRACEABILITY) from ANALYTICS_DB.CULTIVATION.MITTO_PROCESSING_TRACKER_AVERAGES);
              --convert_timezone('America/Chicago', current_timestamp)::date  ;




select * from ANALYTICS_DB.masonl.MITTO_EXPECTED_WEIGHTS_Temp where Projected_FF_Weight > 0
2753
select * from ANALYTICS_DB.masonl.PLACEMENTNEW

select max(PROCESSING_TRACKER_TRACEABILITY) from ANALYTICS_DB.CULTIVATION.MITTO_PROCESSING_TRACKER_AVERAGES


select * from ANALYTICS_DB.BUSINESS.CULTIVATION_YIELDS where state = 'OH' and PLANNER_HARVEST_DATE > '2019-01-01'


