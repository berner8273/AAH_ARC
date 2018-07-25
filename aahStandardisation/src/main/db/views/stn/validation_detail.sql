create or replace view stn.validation_detail
as
select
       v.validation_cd
     , cm.code_module_nm
     , dbt.table_nm
     , dtc.column_nm
     , vt.validation_typ_err_msg
  from
            stn.validation        v
       join stn.validation_type   vt  on v.validation_typ_id = vt.validation_typ_id
       join stn.code_module       cm  on v.code_module_id    = cm.code_module_id
       join stn.validation_column vc  on v.validation_id     = vc.validation_id
       join stn.db_tab_column     dtc on vc.dtc_id           = dtc.dtc_id
       join stn.db_table          dbt on dtc.dbt_id          = dbt.dbt_id
     ;