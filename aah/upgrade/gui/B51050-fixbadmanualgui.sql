

UPDATE gui.gui_jrnl_lines_unposted 
SET jlu_reference_2='NVS'
where 
     jlu_reference_1= 'FSANYAORECOMMUTATION'
    and jlu_reference_2 = 'FSANY';

commit;