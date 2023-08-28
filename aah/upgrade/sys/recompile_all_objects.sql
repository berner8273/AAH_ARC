DECLARE
    cursor c is select * from dba_objects where status != 'VALID';
    last_uncompiled number := -1;
    uncompiled number := 0;
    sqlstr varchar2(1000);
    safety number := 0;
BEGIN
    WHILE last_uncompiled != uncompiled and safety < 10 LOOP
        safety := safety + 1;
        --dbms_output.put_line('pass #'||safety|| ': last uncompiled:' || last_uncompiled || ', curr uncompiled:'||uncompiled);
        FOR rec in c LOOP
            IF rec.object_type = 'PACKAGE BODY' then
                sqlstr := 'alter PACKAGE ' || rec.owner || '.'||rec.object_name || ' compile BODY';
            ELSE
                sqlstr := 'alter ' || rec.object_type || ' ' || rec.owner || '.'||rec.object_name || ' compile';
            END IF;
            --dbms_output.put_line('executing: '||sqlstr);

            BEGIN
                execute immediate sqlstr;
                exception
                    when others then
                    --dbms_output.put_line('compile failed: '||sqlerrm);
                    null; -- no op
            END;
        END LOOP;
        last_uncompiled := uncompiled;
        select count(1) into uncompiled from dba_objects where status != 'VALID';
    END LOOP; 
    dbms_output.put_line('finally: last uncompiled:' || last_uncompiled || ', curr uncompiled:'||uncompiled);
END; 
 /
 