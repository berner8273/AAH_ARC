/* SET OPEN EVENT CLASS YEAR/PERIOD */

accept v_open_year   char prompt 'Open year (four digits):';
accept v_open_period char prompt 'Open period (two digits):';
begin
update
       fdr.fr_general_lookup fgl
   set
       fgl.lk_lookup_value1 = ( case
                                     when lk_match_key2||lk_match_key3 >= &v_open_year||lpad(&v_open_period,2,'0')
                                     then 'O'
                                     else 'C'
                                end )
    , fgl.lk_lookup_value4 = ( case
                                     when lk_match_key2||lk_match_key3 >= &v_open_year||lpad(&v_open_period,2,'0')
                                     then null
                                     else nvl( fgl.lk_lookup_value4 , to_char( sysdate , 'DD-MON-YYYY' ) )
                                end )
where fgl.lk_lkt_lookup_type_code = 'EVENT_CLASS_PERIOD'
;
end;
/

/* SET STATUS OF CORRESPONDING SLR.SLR_ENTITY_PERIODS */

declare v_ent_entity varchar2(30 char);
begin
      for i in (select ent_entity from slr.slr_entities)
      loop
           v_ent_entity := i.ent_entity;
           slr.slr_pkg.pROLL_ENTITY_DATE(v_ent_entity);
      end loop;
end;
/

commit;