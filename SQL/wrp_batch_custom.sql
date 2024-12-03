CREATE OR REPLACE  PACKAGE BODY WRP_BATCH_CUSTOM AS
  /*-----------------------------------------------------------------------------------------------------
        CHANGE HISTORY
     
    Modified By         : Venkatesh Chenchala
 
    Modified Date       : 21-Nov-2024
 
    Change Description  : Collect charges based on Subscription from the customers
 
    Search Tag          : IFBMAMFE processing part of EOD in EOTI stage
     
     -------------------------------------------------------------------------------------------------------
     */

     PROCEDURE dbg(p_msg VARCHAR2) IS
          l_msg VARCHAR2(32767);
     BEGIN
          l_msg := 'wrp_batch_custom ==>' || p_msg;
          debug.pr_debug('AE',
                         l_msg);
     END dbg;

     FUNCTION fn_run_batch(p_branch VARCHAR2, p_user VARCHAR2,
                           p_stage VARCHAR2, p_batch VARCHAR2,
                           p_err_code IN OUT VARCHAR2,
                           p_err_params IN OUT VARCHAR2) RETURN BOOLEAN IS
          l_sql          VARCHAR2(3000);
          l_invalid_proc EXCEPTION;
          PRAGMA EXCEPTION_INIT(l_invalid_proc,
                                -6550);
     BEGIN
          global.set_func_type('B');
          dbg('Going to called wrp_batch_custom.pr_aeod' || p_batch);
          l_sql := 'Begin wrp_batch_custom.pr_aeod' ||
                   dbms_assert.simple_sql_name(p_batch) ||
                   '(:1,:2,:3,:4);End;';
          EXECUTE IMMEDIATE l_sql
               USING IN OUT p_err_code, p_branch, p_user, p_batch;
          dbg('Successfully came back from wrp_batch_custom.pr_aeod' ||
              p_batch);
          RETURN TRUE;
     EXCEPTION
          WHEN l_invalid_proc THEN
               dbg('procedure does not exists...so return false');
               p_err_code := 'AE-OTHR-002';
               RETURN FALSE;
          WHEN OTHERS THEN
               dbg('Some error has occured ' || SQLERRM);
               dbg(dbms_utility.format_error_backtrace);
               IF p_err_code IS NULL THEN
                    p_err_code := 'AE-OTHR-001';
               END IF;
               RETURN FALSE;
     END fn_run_batch;

     PROCEDURE pr_pre_aeoddedupeod(p_errcode IN OUT VARCHAR2,
                                   p_branch VARCHAR2, p_user VARCHAR2,
                                   p_funcid VARCHAR2) IS
     BEGIN
          dbg('Start  of wrp_batch_custom.Pr_Pre_Aeoddedupeod');
          dbg('End  of wrp_batch_custom.Pr_Pre_Aeoddedupeod');
          RETURN;
     EXCEPTION
          WHEN OTHERS THEN
               dbg('Exception in wrp_batch_custom.Pr_Pre_Aeoddedupeod' ||
                   SQLERRM);
               RETURN;
     END pr_pre_aeoddedupeod;

     PROCEDURE pr_post_aeoddedupeod(p_errcode IN OUT VARCHAR2,
                                    p_branch VARCHAR2, p_user VARCHAR2,
                                    p_funcid VARCHAR2) IS
     BEGIN
          dbg('Start  of wrp_batch_custom.Pr_Post_Aeoddedupeod');
          dbg('End  of wrp_batch_custom.Pr_Post_Aeoddedupeod');
          RETURN;
     EXCEPTION
          WHEN OTHERS THEN
               dbg('Exception in wrp_batch_custom.Pr_Post_Aeoddedupeod' ||
                   SQLERRM);
               RETURN;
     END pr_post_aeoddedupeod;

     PROCEDURE pr_post_aeodcgbatch(p_error_code IN OUT VARCHAR2,
                                   p_branch_code IN sttms_branch.branch_code%TYPE,
                                   p_user_id IN smtbs_current_users.user_id%TYPE,
                                   p_function_id IN VARCHAR2) IS
     BEGIN
          dbg('Start of wrp_batch_custom.PR_POST_AEODCGBATCH');
          dbg('End  of wrp_batch_custom.PR_POST_AEODCGBATCH');
          RETURN;
     EXCEPTION
          WHEN OTHERS THEN
               debug.pr_debug('AC',
                              'In when others of procedure pr_aeodrfbaudly');
               p_error_code := '';
               RETURN;
     END pr_post_aeodcgbatch;

     PROCEDURE pr_aeodgidcredt(p_error_code IN OUT VARCHAR2,
                               p_branch_code IN sttms_branch.branch_code%TYPE,
                               p_user_id IN smtbs_current_users.user_id%TYPE,
                               p_function_id IN VARCHAR2) IS
     BEGIN
          dbg('Start of Wrp_Batch_Custom.Pr_Aeodgidcredt');
          IF NOT
              gipks_credit_bureau_report.gen_dcn_cheque_dishonor_file(global.application_date) THEN
               dbg('Failed in Gipks_Credit_Bureau_Report.Gen_Dcn_Cheque_Dishonor_File');
          END IF;
          IF NOT
              gipks_credit_bureau_report.gen_dcm_cheque_dishonor_file(global.application_date) THEN
               dbg('Failed in Gipks_Credit_Bureau_Report.Gen_Dcm_Cheque_Dishonor_File');
          END IF;
          IF NOT
              gipks_credit_bureau_report.gen_con_credit_facility_file(global.application_date) THEN
               dbg('Failed in Gipks_Credit_Bureau_Report.Gen_Dcn_Cheque_Dishonor_File');
          END IF;
          IF NOT
              gipks_credit_bureau_report.gen_com_credit_facility_file(global.application_date) THEN
               dbg('Failed in Gipks_Credit_Bureau_Report.Gen_Dcn_Cheque_Dishonor_File');
          END IF;
          dbg('End  of Wrp_Batch_Custom.Pr_Aeodgidcredt');
          RETURN;
     EXCEPTION
          WHEN OTHERS THEN
               debug.pr_debug('AC',
                              'In when others of procedure Pr_Aeodgidcredt');
               p_error_code := '';
               RETURN;
     END pr_aeodgidcredt;

	 PROCEDURE pr_aeodifdpdcis(p_error_code IN OUT VARCHAR2,
						   p_branch_code IN sttms_branch.branch_code%TYPE,
						   p_user_id IN smtbs_current_users.user_id%TYPE,
						   p_function_id IN VARCHAR2) IS
	 BEGIN
		 dbg('Start of Wrp_Batch_Custom.pr_aeodifdpdcis');
		 ifpks_ifdcrdop_utils_custom.pr_apply_annual_chgs(p_branch_code);
		 RETURN;
	 EXCEPTION
          WHEN OTHERS THEN
               debug.pr_debug('AC',
                              'In when others of procedure pr_aeodifdpdcis');
               p_error_code := '';
               RETURN;
     END pr_aeodifdpdcis;
	 
	 ---IFBMAMFE processing part of EOD in EOTI stage start----------
	 PROCEDURE PR_AEODIFBMAMFE(p_error_code IN OUT VARCHAR2,
						   p_branch_code IN sttms_branch.branch_code%TYPE,
						   p_user_id IN smtbs_current_users.user_id%TYPE,
						   p_function_id IN VARCHAR2) IS
	 BEGIN
		debug.pr_debug('IF','Calling the PR_PROCESS_IFBMAMFE');					
		PR_PROCESS_IFBMAMFE(p_branch_code  Varchar2);
	  RETURN;
	 EXCEPTION
          WHEN OTHERS THEN
               debug.pr_debug('IF',
                              'In when others of procedure PR_AEODIFBMAMFE');
               p_error_code := '';
               RETURN;
     END PR_AEODIFBMAMFE;
							
	 PROCEDURE PR_PROCESS_IFBMAMFE(p_branch_code in Varchar2) AS

  CURSOR cust_ac_cursor IS
    SELECT *
      FROM sttm_cust_account_custom cust, iftm_masarat_sub_model imsm
     WHERE cust.subscription_model = imsm.type_of_package
       AND imsm.record_stat = 'O'
       AND imsm.auth_stat = 'A'
       AND cust.branch_code = p_branch_code
       AND EXISTS (SELECT 1
              FROM sttm_cust_account acc
             WHERE cust_ac_no = cust.cust_ac_no
               AND cust.branch_code = cust.branch_code
               AND acc.record_stat = 'O'
               AND acc.auth_stat = 'A')
    
  l_cust_ac_no         sttm_cust_account_custom.cust_ac_no%TYPE;
  l_branch_code        sttm_cust_account_custom.branch_code%TYPE;
  l_subscription_model sttm_cust_account_custom.subscription_model%TYPE;
  g_charge_type        iftm_masarat_sub_model.type_of_package%TYPE;
  g_charge_amount      iftm_masarat_sub_model.charge_amount%TYPE;
  g_charge_currency    iftm_masarat_sub_model.charge_currency%TYPE;
  g_freq_of_charge     iftm_masarat_sub_model.freq_of_charge%TYPE;
  g_chg_income_gl      iftm_masarat_sub_model.chg_income_gl%TYPE;
  g_chg_txn_code       iftm_masarat_sub_model.chg_txn_code%TYPE;
  g_chg_prod           iftm_masarat_sub_model.chg_prod%TYPE;

BEGIN

  FOR cust_record IN cust_ac_cursor LOOP
  
    l_cust_ac_no         := cust_record.cust_ac_no;
    l_branch_code        := cust_record.branch_code;
    l_subscription_model := cust_record.subscription_model;
    g_charge_type        := cust_record.charge_type;
    g_charge_amount      := cust_record.charge_amount;
    g_charge_currency    := cust_record.charge_currency;
    g_freq_of_charge     := cust_record.freq_of_charge;
    g_chg_income_gl      := cust_record.chg_income_gl;
    g_chg_txn_code       := cust_record.chg_txn_code;
    g_chg_prod           := cust_record.chg_prod;
  
    debug.pr_debug('IF', 'Customer: ' || l_cust_ac_no);
    debug.pr_debug('IF', 'Branch: ' || l_branch_code);
    debug.pr_debug('IF', 'Subscription Model: ' || l_subscription_model);
    debug.pr_debug('IF', 'Charge Type: ' || g_charge_type);
    debug.pr_debug('IF', 'Charge Amount: ' || g_charge_amount);
    debug.pr_debug('IF', 'Charge Currency: ' || g_charge_currency);
    debug.pr_debug('IF', 'Charge Frequency: ' || g_freq_of_charge);
    debug.pr_debug('IF', 'Charge Income GL: ' || g_chg_income_gl);
    debug.pr_debug('IF', 'Charge Transaction Code: ' || g_chg_txn_code);
    debug.pr_debug('IF', 'Charge Product: ' || g_chg_prod);
  END LOOP;
  RETURN;
EXCEPTION
  WHEN OTHERS THEN
    debug.pr_debug('Error occurred: ' || SQLERRM);
    RETURN;
END PROCESS_IFBMAMFE;
 ---IFBMAMFE processing part of EOD in EOTI stage end----------
																
END wrp_batch_custom;
/
