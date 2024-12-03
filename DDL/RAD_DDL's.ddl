CREATE TABLE IFTM_MASARAT_SUB_MODEL(
TYPE_OF_PACKAGE  NOT NULL VARCHAR2(100),PRIMARY KEY     
CHARGE_AMOUNT             NUMBER            
CHARGE_CURRENCY  NOT NULL VARCHAR2(3)       
FREQ_OF_CHARGE   NOT NULL VARCHAR2(1)       
CHG_INCOME_GL    NOT NULL VARCHAR2(20)      
CHG_TXN_CODE     NOT NULL VARCHAR2(3)       
CHG_PROD         NOT NULL VARCHAR2(4)       
AUTH_STAT                 CHAR(1)           
MOD_NO                    CHAR(1)           
MAKER_ID                  VARCHAR2(12 CHAR) 
MAKER_DT_STAMP            DATE              
CHECKER_ID                VARCHAR2(12 CHAR) 
CHECKER_DT_STAMP          DATE              
ONCE_AUTH                 CHAR(1 CHAR)      
RECORD_STAT               CHAR(1) 
);