CREATE OR REPLACE PACKAGE BODY ifpks_masarat_chg_process AS
PROCEDURE dbg(p_msg VARCHAR2) IS

          l_msg VARCHAR2(32767);

     BEGIN

          IF debug.pkg_debug_on <> 2 THEN

               l_msg := 'ifpks_masarat_chg_process ==>' || p_msg;

               debug.pr_debug('IF', l_msg);

          END IF;

     END dbg;
 


  FUNCTION FN_PROCESS_CHARGES(p_branch_code IN VARCHAR2,
                                 p_account IN VARCHAR2,
                                 p_customer IN VARCHAR2, p_prod IN VARCHAR2,
                                 p_ofs_acc IN VARCHAR2,
                                 p_amt IN NUMBER,
                                 p_err_code IN OUT VARCHAR2,
                                 p_err_params IN OUT VARCHAR2) RETURN BOOLEAN IS
          RESULT         BOOLEAN;
          l_xref         VARCHAR2(16);
          l_serial_no    VARCHAR2(16);
          l_reference_no VARCHAR2(16);
     BEGIN
          dbg('Inside pr_process_entries');
          l_xref := 'FJB' || to_char(global.application_date,
                                     'YYDDD') ||
                    lpad(txnseqfjb.nextval,
                         8,
                         0);
          IF NOT trpkss.fn_get_product_refno(global.current_branch,
                                             p_prod,
                                             global.application_date,
                                             l_serial_no,
                                             l_reference_no,
                                             p_err_code) THEN
               ROLLBACK;
               RETURN FALSE;
          END IF;
          dbg('l_xref:' || l_xref);
          INSERT INTO detbs_rtl_teller
               (scode,
                xref,
                branch_code,
                product_code,
                trn_dt,
                txn_branch,
                txn_ccy,
                txn_amount,
                txn_acc,
                ofs_ccy,
                ofs_amount,
                ofs_acc,
                lcy_amount,
                exch_rate,
                value_dt,
                rel_customer,
                ofs_branch,
                narrative,
                trn_ref_no)
          VALUES
               ('FLEXBRANCH',
                l_xref,
                global.current_branch,
                p_prod,
                global.application_date,
                p_branch_code,
                'LYD',
                p_amt,
                p_account,
                'LYD',
                p_amt,
                p_ofs_acc,
                p_amt,
                NULL,
                global.application_date,
                p_customer,
                p_branch_code,
                'Charge for release of uncollected fund for' ||
                null,
                l_reference_no);
          RESULT := depkss_rtl_teller.fn_upload(l_xref,
                                                p_err_code,
                                                p_err_params);
          IF NOT (RESULT) THEN
               dbg('Failed in accounting');
               RETURN FALSE;
          END IF;
          IF NOT depkss_rtl_teller.fn_rtl_teller_auth(global.current_branch,
                                                      l_reference_no,
                                                      global.user_id,
                                                      global.lcy,
                                                      p_err_code,
                                                      p_err_params) THEN
               dbg('Failed in accounting');
               RETURN FALSE;
          END IF;
          dbg('REturning from pr_process_entries');
          RETURN TRUE;
     EXCEPTION
          WHEN OTHERS THEN
               dbg('Failed in accounting');
               ROLLBACK;
               RETURN FALSE;
    END FN_PROCESS_CHARGES ;

 PROCEDURE PR_PROCESS_IFBMAMFE(p_branch_code in Varchar2) AS
 
		
 l_cust_no        varchar2(20);
 p_err_code       varchar2(220);
 p_err_params     varchar2(220);
 

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
               AND acc.auth_stat = 'A');
    
  l_cust_ac_no         sttm_cust_account_custom.cust_ac_no%TYPE;
  l_branch_code        sttm_cust_account_custom.branch_code%TYPE;
  l_subscription_model sttm_cust_account_custom.subscription_model%TYPE;
  l_charge_type        iftm_masarat_sub_model.type_of_package%TYPE;
  l_charge_amount      iftm_masarat_sub_model.charge_amount%TYPE;
  l_charge_currency    iftm_masarat_sub_model.charge_currency%TYPE;
  l_freq_of_charge     iftm_masarat_sub_model.freq_of_charge%TYPE;
  l_chg_income_gl      iftm_masarat_sub_model.chg_income_gl%TYPE;
  l_chg_txn_code       iftm_masarat_sub_model.chg_txn_code%TYPE;
  l_chg_prod           iftm_masarat_sub_model.chg_prod%TYPE;

BEGIN

  FOR cust_record IN cust_ac_cursor LOOP
  
    l_cust_ac_no         := cust_record.cust_ac_no;
    l_branch_code        := cust_record.branch_code;
    l_subscription_model := cust_record.subscription_model;
    l_charge_type        := cust_record.type_of_package;
    l_charge_amount      := cust_record.charge_amount;
    l_charge_currency    := cust_record.charge_currency;
    l_freq_of_charge     := cust_record.freq_of_charge;
    l_chg_income_gl      := cust_record.chg_income_gl;
    l_chg_txn_code       := cust_record.chg_txn_code;
    l_chg_prod           := cust_record.chg_prod;
  
    debug.pr_debug('IF', 'Customer: ' || l_cust_ac_no);
    debug.pr_debug('IF', 'Branch: ' || l_branch_code);
    debug.pr_debug('IF', 'Subscription Model: ' || l_subscription_model);
    debug.pr_debug('IF', 'Charge Type: ' || l_charge_type);
    debug.pr_debug('IF', 'Charge Amount: ' || l_charge_amount);
    debug.pr_debug('IF', 'Charge Currency: ' || l_charge_currency);
    debug.pr_debug('IF', 'Charge Frequency: ' || l_freq_of_charge);
    debug.pr_debug('IF', 'Charge Income GL: ' || l_chg_income_gl);
    debug.pr_debug('IF', 'Charge Transaction Code: ' || l_chg_txn_code);
    debug.pr_debug('IF', 'Charge Product: ' || l_chg_prod);
	
  select cust_no INTO l_cust_no from sttm_cust_account where cust_no=l_cust_no;	
	IF NOT FN_PROCESS_CHARGES(l_branch_code,l_cust_ac_no,l_cust_no,l_chg_prod,l_chg_income_gl,l_charge_amount,p_err_code,p_err_params)THEN
	 
	 debug.pr_debug('IF','failed to process the charges');
	 ROLLBACK;
	 RETURN;
	
	END IF;
	
  END LOOP;
  RETURN;
EXCEPTION
  WHEN OTHERS THEN
    debug.pr_debug('IF','Error occurred: ' || SQLERRM);
    RETURN;
END PR_PROCESS_IFBMAMFE;

END ifpks_masarat_chg_process;