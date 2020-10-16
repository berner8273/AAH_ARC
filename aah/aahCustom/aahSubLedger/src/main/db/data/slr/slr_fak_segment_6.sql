INSERT INTO slr.slr_fak_segment_6 (
            fs6_entity_set,
            fs6_segment_value,
            fs6_segment_description,
            fs6_status,
            fs6_created_by,
            fs6_created_on,
            fs6_amended_by,
            fs6_amended_on)
    SELECT  'ENT_SEGMENT_6_SET',
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