INSERT INTO slr.slr_fak_segment_3 (
            fs3_entity_set,
            fs3_segment_value,
            fs3_segment_description,
            fs3_status,
            fs3_created_by,
            fs3_created_on,
            fs3_amended_by,
            fs3_amended_on)
    SELECT  'ENT_SEGMENT_3_SET',
            'NVS',
            'No Value Supplied',
            'A',
            USER,
            TRUNC(SYSDATE),
            USER,
            TRUNC(SYSDATE)
      FROM  dual
;
commit;