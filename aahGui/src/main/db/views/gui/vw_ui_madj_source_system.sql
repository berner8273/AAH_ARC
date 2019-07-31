/* Formatted on 3/5/2019 3:16:14 PM (QP5 v5.252.13127.32847) */
CREATE OR REPLACE FORCE VIEW GUI.VW_UI_MADJ_SOURCE_SYSTEM
(
   SI_SYS_INST_ID,
   SI_SYS_INST_NAME
)
   BEQUEATH DEFINER
AS
   SELECT si_sys_inst_id,
          si_sys_inst_id || ' - ' || si_sys_inst_name si_sys_inst_name
     FROM (SELECT 'MADJGEN' si_sys_inst_id, 'MADJ General' si_sys_inst_name FROM DUAL
             UNION ALL
           SELECT 'MADJGEN-CR' si_sys_inst_id, 'Contingency Reserves' si_sys_inst_name FROM DUAL
           UNION ALL  
           SELECT 'MADJGEN-OTHER' si_sys_inst_id, 'Other' si_sys_inst_name FROM DUAL             
            UNION ALL
           SELECT 'MADJGEN-USGAAPFX' si_sys_inst_id, 'US GAAP FX' si_sys_inst_name FROM DUAL
            UNION ALL
           SELECT 'MADJGEN-UKGAAP' si_sys_inst_id, 'UK GAAP' si_sys_inst_name FROM DUAL
            UNION ALL
           SELECT 'MADJGEN-AGMDAC' si_sys_inst_id, 'AGM Consolidated DAC' si_sys_inst_name FROM DUAL
           UNION ALL
           SELECT si_sys_inst_clicode si_sys_inst_id,
                  NVL (si_sys_inst_name, 'NVS') si_sys_inst_name
             FROM fdr.fr_system_instance
            WHERE     si_active = 'A'
                  AND si_sys_inst_id != '1'
                  AND si_sys_inst_id != 'Client Static'
           UNION ALL
           SELECT SUBSTR ('MADJ' || si_sys_inst_clicode, 1, 20)
                     si_sys_inst_id,
                  'MADJ ' || NVL (si_sys_inst_name, 'NVS') si_sys_inst_name
             FROM fdr.fr_system_instance
            WHERE     si_active = 'A'
                  AND si_sys_inst_id != '1'
                  AND si_sys_inst_id != 'Client Static');