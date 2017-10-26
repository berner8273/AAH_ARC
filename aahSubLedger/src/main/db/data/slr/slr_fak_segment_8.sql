INSERT INTO slr.slr_fak_segment_8 (
            fs8_entity_set,
            fs8_segment_value,
            fs8_segment_description,
            fs8_status,
            fs8_created_by,
            fs8_created_on,
            fs8_amended_by,
            fs8_amended_on)
    SELECT  'ENT_SEGMENT_8_SET',
            'NVS',
            'No Value Supplied',
            'A',
            USER,
            TRUNC(SYSDATE),
            USER,
            TRUNC(SYSDATE)
      FROM  dual
;