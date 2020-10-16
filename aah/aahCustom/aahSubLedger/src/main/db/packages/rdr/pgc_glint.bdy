Create or Replace Package Body rdr.pgc_glint
/* Package Body for Custom GL Interface Process(es). */
As

/* Local Constants. */
lgcUnitName Constant all_objects.object_name%TYPE := 'PGC_GLINT';

/* Public Procedure. */
Procedure pCustom(
  pinControlID in rr_interface_control.rgic_id%TYPE)
Is
/* Constants. */
lcUnitName  Constant all_procedures.procedure_name%TYPE := 'pCustom';

Begin
  Null;
End pCustom;

End pgc_glint;
/