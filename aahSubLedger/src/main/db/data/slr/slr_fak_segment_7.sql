INSERT INTO slr.slr_fak_segment_7 (
            fs7_entity_set,
            fs7_segment_value,
            fs7_segment_description,
            fs7_status,
            fs7_created_by,
            fs7_created_on,
            fs7_amended_by,
            fs7_amended_on)
    SELECT  'ENT_SEGMENT_7_SET',
            'NVS',
            'No Value Supplied',
            'A',
            USER,
            TRUNC(SYSDATE),
            USER,
            TRUNC(SYSDATE)
      FROM  dual
;