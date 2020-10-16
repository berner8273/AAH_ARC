INSERT INTO slr.slr_fak_segment_4 (
            fs4_entity_set,
            fs4_segment_value,
            fs4_segment_description,
            fs4_status,
            fs4_created_by,
            fs4_created_on,
            fs4_amended_by,
            fs4_amended_on)
    SELECT  'ENT_SEGMENT_4_SET',
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