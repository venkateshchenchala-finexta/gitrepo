CREATE OR REPLACE PACKAGE ifpks_masarat_chg_process AS

  PROCEDURE PR_PROCESS_IFBMAMFE(p_branch_code IN VARCHAR2);
  
  FUNCTION FN_PROCESS_CHARGES(
    p_branch_code         IN VARCHAR2,
    p_account             IN VARCHAR2,
    p_customer            IN VARCHAR2,
    p_prod                IN VARCHAR2,
    p_ofs_acc             IN VARCHAR2,
    p_amt                 IN NUMBER,
    p_err_code            IN OUT VARCHAR2,
    p_err_params          IN OUT VARCHAR2
  ) RETURN BOOLEAN;

END ifpks_masarat_chg_process;