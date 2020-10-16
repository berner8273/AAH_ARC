INSERT INTO slr.slr_fak_segment_5 (
            fs5_entity_set,
            fs5_segment_value,
            fs5_segment_description,
            fs5_status,
            fs5_created_by,
            fs5_created_on,
            fs5_amended_by,
            fs5_amended_on)
    SELECT  'ENT_SEGMENT_5_SET',
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