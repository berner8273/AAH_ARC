package com.aptitudesoftware.test.aah;

import com.aptitudesoftware.test.tlf.database.IDatabaseConnector;

import java.sql.Connection;
import java.sql.CallableStatement;
import java.sql.SQLException;

import org.apache.log4j.Logger;

public class AAHCleardownOperations
{
    private static final Logger              LOG         = Logger.getLogger ( AAHCleardownOperations.class );
    private static final IDatabaseConnector  DB_CONN_OPS = AAHDatabaseConnectorFactory.getDatabaseConnector ();
    private static final AAHTokenReplacement AAH_TOK_REP = new AAHTokenReplacement();
    
    public static void cleardown () throws Exception
    {
        Connection        conn  = null;
        CallableStatement cStmt = null;

        LOG.debug ( "Deleting all test data from FR_LOG." );

        final String CLEARDOWN_SQL =   "begin\n"
                                     + "   delete from @fdrUsername@.fr_log;\n"
                                     + "end;";

        try
        {
            conn = DB_CONN_OPS.getConnection ();

            LOG.debug ( "A connection to the database was successfully retrieved" );

            cStmt = conn.prepareCall ( AAH_TOK_REP.replaceTokensInString(CLEARDOWN_SQL) );

            LOG.debug ( "The delete statements were successfully prepared" );

            cStmt.execute ();

            LOG.debug ( "The delete statements were successfully executed" );

            conn.commit ();

            LOG.debug ( "The changes were committed to the database" );
        }
        catch ( SQLException sqle )
        {
            LOG.error ( "SQLException : " + sqle );

            throw sqle;
        }
        finally
        {
            cStmt.close ();

            conn.close ();
        }
    }
    
    public static void clearTable (AAHTablenameConstants pTable) throws Exception
    {
    	clearTable (pTable, null);
    }
    
    public static void clearTable (AAHTablenameConstants pTable, String pWhereClause) throws Exception
        {
        Connection        conn  = null;
        CallableStatement cStmt = null;

        LOG.debug ( "Deleting test data from " + pTable + "." );

        final String CLEARDOWN_SQL = "delete from " + pTable 
                                     + ((pWhereClause == null || pWhereClause.isEmpty()) ? "" : " where " + pWhereClause + "");

        LOG.debug("CLEARDOWN_SQL: " + AAH_TOK_REP.replaceTokensInString(CLEARDOWN_SQL) );
        try
        {
            conn = DB_CONN_OPS.getConnection ();
            LOG.debug ( "A connection to the database was successfully retrieved" );

            LOG.debug(conn.nativeSQL(AAH_TOK_REP.replaceTokensInString(CLEARDOWN_SQL)));
            cStmt = conn.prepareCall ( AAH_TOK_REP.replaceTokensInString(CLEARDOWN_SQL) );
            LOG.debug ( "The delete statements were successfully prepared" );

            cStmt.execute ();
            LOG.debug ( "The delete statements were successfully executed" );

            conn.commit ();
            LOG.debug ( "The changes were committed to the database" );
        }
        catch ( SQLException sqle )
        {
            LOG.error ( "SQLException : " + sqle );
            throw sqle;
        }
        finally
        {
            cStmt.close ();
            conn.close ();
        }
    }
    
    public static void fullCleardown () throws Exception
    {
        Connection        conn  = null;
        CallableStatement cStmt = null;

        LOG.debug ( "Deleting all test data from the database." );

        final String CLEARDOWN_SQL =   "begin\n"
                                     + "   delete from stn.feed_record_count;"
                                     + "   delete from stn.broken_feed;"
                                     + "   delete from stn.superseded_feed;"
                                     + "   delete from stn.feed;"
                                     + "   delete from stn.step_run_param;"
                                     + "   delete from stn.step_run_state;"
                                     + "   delete from stn.step_run;"
                                     + "   delete from stn.fx_rate;"
                                     + "   delete from stn.step_run_log;"
                                     + "   delete from stn.gl_account;"
                                     + "   delete from stn.department;"
                                     + "   delete from stn.gl_chartfield;"
                                     + "   delete from stn.legal_entity_link;"
                                     + "   delete from stn.legal_entity;"
                                     + "   delete from stn.elimination_legal_entity;"
                                     + "   delete from stn.vie_legal_entity;"
                                     + "   delete from stn.cession_event;"
                                     + "   delete from stn.insurance_policy_fx_rate;"
                                     + "   delete from stn.insurance_policy_tax_jurisd;"
                                     + "   delete from stn.tax_jurisdiction;"
                                     + "   delete from stn.cession_link;"
                                     +" execute immediate 'alter table stn.cession_link disable constraint fk_cc_cl';"
                                     +" execute immediate 'alter table stn.cession_link disable constraint fk_pc_cl';"
                                     + "   delete from stn.cession;"
                                     +" execute immediate 'alter table stn.cession_link enable constraint fk_cc_cl';"
                                     +" execute immediate 'alter table stn.cession_link enable constraint fk_pc_cl';"
                                     +" execute immediate 'alter table stn.insurance_policy_tax_jurisd disable constraint fk_ip_iptj';"
                                     +" execute immediate 'alter table stn.cession disable constraint fk_ip_c';"
                                     +" execute immediate 'alter table stn.insurance_policy_fx_rate disable constraint fk_ip_ipfr';"
                                     + "   delete from stn.insurance_policy;"
                                     + "   delete from stn.gl_combo_edit_assignment;"
                                     + "   delete from stn.gl_combo_edit_rule;"
                                     + "   delete from stn.gl_combo_edit_process;"
                                     + "   delete from stn.journal_line;"
                                     +" execute immediate 'alter table stn.insurance_policy_tax_jurisd enable constraint fk_ip_iptj';"
                                     +" execute immediate 'alter table stn.cession enable constraint fk_ip_c';"
                                     +" execute immediate 'alter table stn.insurance_policy_fx_rate enable constraint fk_ip_ipfr';"
                                     + "   delete from stn.accounting_basis_ledger;"
                                     + "   delete from stn.legal_entity_ledger;"
                                     + "   delete from stn.ledger;"
                                     + "   delete from stn.event_hierarchy;"
                                     + "   delete from fdr.fr_stan_raw_fx_rate; "
                                     + "   delete from fdr.fr_fx_rate;"
                                     + "   delete from fdr.fr_rate_type_lookup              where rtyl_lookup_key           not in ( '1' , 'SPOT' , 'FORWARD' , 'MAVG' );"
                                     + "   delete from fdr.fr_rate_type                     where rty_rate_type_id          not in ( '1' , 'SPOT' , 'FORWARD' , 'MAVG' );"
                                     + "   delete from fdr.fr_stan_raw_party_legal; "
                                     + "   delete from fdr.fr_stan_raw_party_business; "
                                     + "   execute immediate 'alter table fdr.fr_log_text disable constraint fk_lo_lot_i';"
                                     + "   delete from fdr.fr_log_text;"
                                     + "   execute immediate 'truncate table fdr.fr_log';"
                                     + "   execute immediate 'alter table fdr.fr_log_text enable constraint fk_lo_lot_i';"
                                     + "   delete from fdr.fr_stan_raw_int_entity;"
                                     + "   delete from fdr.fr_stan_raw_gl_account;"
                                     + "   delete from fdr.fr_stan_raw_book;"
                                     + "   delete from fdr.fr_stan_raw_general_codes;"
                                     + "   delete from fdr.fr_stan_raw_general_lookup;"
                                     + "   delete from fdr.fr_stan_raw_org_hier_node;"
                                     + "   delete from fdr.fr_stan_raw_org_hier_struc;"
                                     + "   delete from fdr.fr_stan_raw_insurance_policy;"
                                     + "   delete from fdr.fr_stan_raw_adjustment;"
                                     + "   delete from fdr.fr_general_codes                 where gc_gct_code_type_id       in ( 'GL_CHARTFIELD' , 'TAX_JURISDICTION' , 'POLICY_TAX' , 'JOURNAL_LINE' );"
                                     + "   delete from fdr.fr_general_codes                 where gc_gct_code_type_id       like 'COMBO%';"
                                     + "   delete from fdr.fr_general_code_types            where gct_code_type_id          like 'COMBO%';"
                                     + "   delete from fdr.fr_general_lookup                where lk_lkt_lookup_type_code   in ( 'ACCOUNTING_BASIS_LEDGER' , 'LEGAL_ENTITY_LEDGER' , 'EVENT_CLASS_PERIOD' , 'LEGAL_ENTITY_ALIAS' , 'COMBO_RULESET'); "
                                     + "   delete from fdr.fr_gl_account_lookup gal         where gal_ga_lookup_key         != '1' and not exists ( select null from fdr.fr_gl_account ga where ga.ga_account_code = gal.gal_ga_account_code and ga.ga_input_by = 'AG_SEED' );"
                                     + "   delete from fdr.fr_gl_account                    where ga_account_code           != '1' and ga_input_by != 'AG_SEED';"
                                     + "   delete from fdr.fr_gl_account_aud;"
                                     + "   update fdr.fr_batch_schedule set bs_records_processed = 0 , bs_records_failed = 0;"
                                     + "   delete from fdr.fr_batch_schedule_hist_details;"
                                     + "   delete from fdr.fr_trade                         where t_fdr_tran_no             not in ( 'DEFAULT' ); "
                                     + "   delete from fdr.fr_book_lookup                   where bol_lookup_key            != 'DEFAULT';"
                                     + "   delete from fdr.fr_book                          where bo_book_clicode           != 'DEFAULT';"
                                     + "   delete from fdr.fr_instrument                    where i_instrument_id           not in ( '1' , 'INSURANCE_POLICY' ); "
                                     + "   delete from fdr.fr_instrument_lookup             where ilo_i_instr_id            not in ( 'INSURANCE_POLICY' ); "
                                     + "   delete from fdr.fr_instr_insure_extend;"
                                     + "   delete from fdr.fr_int_proc_entity_lookup        where ipel_lookup_key           not in ('NVS' , 'DEFAULT');"
                                     + "   delete from fdr.fr_internal_proc_entity          where ipe_entity_client_code    not in ('NVS' , 'DEFAULT'); "
                                     + "   delete from fdr.fr_posting_schema                where ps_input_by               not in ( 'FDR' );"
                                     + "   delete from fdr.fr_party_business_lookup         where pbl_sil_sys_inst_clicode  not in ('DEFAULT');  "
                                     + "   delete from fdr.fr_party_business                where pbu_party_bus_client_code not in ('DEFAULT'); "
                                     + "   delete from fdr.fr_org_node_structure            where ons_on_child_org_node_id  != 1;"
                                     + "   delete from fdr.fr_org_network                   where on_org_node_client_code   not in ('DEFAULT');"
                                     + "   delete from fdr.fr_entity_schema;"
                                     + "   delete from fdr.fr_party_legal_lookup            where pll_lookup_key            not in ('1','NVS');"
                                     + "   delete from fdr.fr_party_legal_type              where plt_pl_party_legal_id     != '1';"
                                     + "   delete from fdr.fr_party_legal                   where pl_party_legal_clicode    not in ('1','NVS');"
                                     + "   delete from fdr.fr_lpg_config;"
                                     + "   delete from fdr.fr_accounting_event;"
                                     + "   delete from fdr.fr_accounting_event_imp;"
                                     + "   delete from fdr.fr_stan_raw_acc_event;"
                                     + "   delete from fdr.fr_instr_insure_extend;"
                                     + "   delete from fdr.fr_posting_schema                where ps_input_by               not in ( 'FDR' );"
                                     + "   delete from slr.slr_bm_entity_processing_set;"
                                     + "   delete from slr.slr_entities;"
                                     + "   delete from slr.slr_eba_definitions;"
                                     + "   delete from slr.slr_fak_definitions;"
                                     + "   delete from slr.slr_entity_accounts;"
                                     + "   delete from slr.slr_entity_currencies;"
                                     + "   delete from slr.slr_entity_days;"
                                     + "   delete from slr.slr_entity_periods;"
                                     + "   delete from slr.slr_entity_periods_aud;"
                                     + "   delete from slr.slr_entity_grace_days;"
                                     + "   delete from slr.slr_entity_proc_group;"
                                     + "   delete from slr.slr_entity_rates;"
                                     + "   delete from slr.slr_fak_daily_balances;"
                                     + "   delete from slr.slr_eba_daily_balances;"
                                     + "   delete from slr.slr_eba_combinations;"
                                     + "   delete from slr.slr_fak_combinations;"
                                     + "   delete from slr.slr_eba_bop_amounts;"
                                     + "   delete from slr.slr_fak_bop_amounts;"
                                     + "   delete from slr.slr_jrnl_lines_unposted;"
                                     + "   delete from slr.slr_jrnl_lines;"
                                     + "   delete from slr.slr_jrnl_headers_unposted;"
                                     + "   delete from slr.slr_jrnl_headers;"
                                     + "   delete from slr.slr_jrnl_line_errors;"
                                     + "   delete from slr.slr_fak_segment_3                where fs3_segment_value         not in ( 'NVS' );"
                                     + "   delete from slr.slr_fak_segment_4                where fs4_segment_value         not in ( 'NVS' );"
                                     + "   delete from slr.slr_fak_segment_5                where fs5_segment_value         not in ( 'NVS' );"
                                     + "   delete from slr.slr_fak_segment_6                where fs6_segment_value         not in ( 'NVS' );"
                                     + "   delete from slr.slr_fak_segment_7                where fs7_segment_value         not in ( 'NVS' );"
                                     + "   delete from slr.slr_fak_segment_8                where fs8_segment_value         not in ( 'NVS' );"
                                     + "   delete from slr.slr_job_statistics;"
                                     + "   delete from slr.slr_job_trace;"
                                     + "   delete from slr.slr_log;" 
									 + "   delete from rdr.rr_glint_journal_line;"
                                     + "   delete from rdr.rr_glint_journal_mapping;"
                                     + "   delete from rdr.rr_glint_journal;"
                                     + "   delete from rdr.rr_glint_batch_control;"
                                     + "   delete from rdr.rr_interface_control;"
                                     + "end;";

        try
        {
            conn = DB_CONN_OPS.getConnection ();

            LOG.debug ( "A connection to the database was successfully retrieved" );

            cStmt = conn.prepareCall ( CLEARDOWN_SQL );

            LOG.debug ( "The delete statements were successfully prepared" );

            cStmt.execute ();

            LOG.debug ( "The delete statements were successfully executed" );

            conn.commit ();

            LOG.debug ( "The changes were committed to the database" );
        }
        catch ( SQLException sqle )
        {
            LOG.error ( "SQLException : " + sqle );

            throw sqle;
        }
        finally
        {
            cStmt.close ();

            conn.close ();
        }
    }
}
