CREATE OR REPLACE PACKAGE BODY slr.SLR_PKG AS
    PROCEDURE pr_fx_rate
        (
            p_lpg_id IN NUMBER,
            p_no_processed_records OUT NUMBER,
            p_no_failed_records OUT NUMBER
        )
    AS
        s_proc_name varchar2(50) := $$plsql_unit || '.' || $$plsql_function ;
    begin
        merge
         into
              slr.slr_entity_rates er
        using (
                  select
                         rs.ent_rate_set              er_entity_set
                       , fx.fr_fxrate_date            er_date
                       , fx.fr_cu_currency_numer_id   er_ccy_from
                       , fx.fr_cu_currency_denom_id   er_ccy_to
                       , fx.fr_fx_rate                er_rate
                       , fx.fr_rty_rate_type_id       er_rate_type
                    from
                                    fdr.fr_fx_rate fx
                         cross join (
                                        select
                                               distinct
                                                        ent_rate_set
                                          from
                                               slr.slr_entities
                                    )
                                    rs
                   where
                         fx.fr_fx_rate is not null
              )
              input
           on (
                      er.er_entity_set = input.er_entity_set
                  and er.er_date       = input.er_date
                  and er.er_ccy_from   = input.er_ccy_from
                  and er.er_ccy_to     = input.er_ccy_to
                  and er.er_rate_type  = input.er_rate_type
              )
        when
              matched then update
                              set
                                  er.er_rate = input.er_rate
        when not
              matched then insert
                           (
                               er_entity_set
                           ,   er_date
                           ,   er_ccy_from
                           ,   er_ccy_to
                           ,   er_rate
                           ,   er_rate_type
                           ,   er_created_by
                           ,   er_created_on
                           ,   er_amended_by
                           ,   er_amended_on
                           )
                           values
                           (
                               input.er_entity_set
                           ,   input.er_date
                           ,   input.er_ccy_from
                           ,   input.er_ccy_to
                           ,   input.er_rate
                           ,   input.er_rate_type
                           ,   user
                           ,   sysdate
                           ,   user
                           ,   sysdate
                           );
        p_no_processed_records := SQL%ROWCOUNT;
        p_no_failed_records := 0;
    end pr_fx_rate;
    PROCEDURE pr_account
        (
            p_lpg_id IN NUMBER,
            p_no_processed_records OUT NUMBER,
            p_no_failed_records OUT NUMBER
        )
    AS
        s_proc_name varchar2(50) := $$plsql_unit || '.' || $$plsql_function ;
    begin
        merge
         into
              slr.slr_entity_accounts ea
        using (
                  select
                         eas.ent_accounts_set            ea_entity_set
                       , ga.ga_account_code              ea_account
                       , nvl(ga.ga_account_type, 'X')    ea_account_type
                       , ga.ga_account_type_flag         ea_account_type_flag
                       , ga.ga_position_flag             ea_position_flag
                       , ga.ga_revaluation_ind           ea_revaluation_flag
                       , nvl(ga.ga_account_name, 'NVS')  ea_description
                       , ga.ga_active                    ea_status
                       , ga.ga_valid_from                ea_eff_from
                       , ga.ga_valid_to                  ea_eff_to
                    from
                                    fdr.fr_gl_account ga
                         cross join (
                                        select
                                               distinct
                                                        ent_accounts_set
                                          from
                                               slr.slr_entities
                                    )
                                    eas
              )
              input
           on (
                      ea.ea_entity_set   = input.ea_entity_set
                  and ea.ea_account      = input.ea_account
              )
        when
              matched then update
                              set
                                  ea.ea_account_type      = input.ea_account_type
                              ,   ea.ea_account_type_flag = input.ea_account_type_flag
                              ,   ea.ea_position_flag     = input.ea_position_flag
                              ,   ea.ea_revaluation_flag  = input.ea_revaluation_flag
                              ,   ea.ea_description       = input.ea_description
                              ,   ea.ea_status            = input.ea_status
                              ,   ea.ea_eff_from          = input.ea_eff_from
                              ,   ea.ea_eff_to            = input.ea_eff_to
        when not
              matched then insert
                           (
                               ea_entity_set
                           ,   ea_account
                           ,   ea_account_type
                           ,   ea_account_type_flag
                           ,   ea_position_flag
                           ,   ea_revaluation_flag
                           ,   ea_description
                           ,   ea_status
                           ,   ea_eff_from
                           ,   ea_eff_to
                           ,   ea_created_by
                           ,   ea_created_on
                           ,   ea_amended_by
                           ,   ea_amended_on
                           )
                           values
                           (
                               input.ea_entity_set
                           ,   input.ea_account
                           ,   input.ea_account_type
                           ,   input.ea_account_type_flag
                           ,   input.ea_position_flag
                           ,   input.ea_revaluation_flag
                           ,   input.ea_description
                           ,   input.ea_status
                           ,   input.ea_eff_from
                           ,   input.ea_eff_to
                           ,   user
                           ,   sysdate
                           ,   user
                           ,   sysdate
                           );
        p_no_processed_records := SQL%ROWCOUNT;
        p_no_failed_records := 0;
    end pr_account;
END SLR_PKG;
/