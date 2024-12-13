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
		ifpks_masarat_chg_process.PR_PROCESS_IFBMAMFE(p_branch_code  Varchar2);
	  RETURN;
	 EXCEPTION
          WHEN OTHERS THEN
               debug.pr_debug('IF',
                              'In when others of procedure PR_AEODIFBMAMFE');
               p_error_code := '';
               RETURN;
     END PR_AEODIFBMAMFE;
							
	 
 ---IFBMAMFE processing part of EOD in EOTI stage end----------
																
END wrp_batch_custom;

