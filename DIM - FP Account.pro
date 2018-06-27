601,100
602,"DIM - FP Account"
928,0
593,
594,
595,
597,
598,
596,
800,
801,
566,61
  SELECT ACCOUNT_CODE,

TESTING 1,2,3;
         ACCOUNT_DESC,
         ACCOUNT_EFF_DATE,
         ACCOUNT_STATUS,
         LEVEL_6_NODE_DESC,
         LEVEL_5_NODE_DESC,
         LEVEL_4_NODE_DESC,
         LEVEL_3_NODE_DESC,
         LEVEL_2_NODE_DESC,
         LEVEL_1_NODE_DESC,
         NVL (LEVEL_7_NODE_NUM,
              (SELECT LEVEL_7_NODE_NUM
                 FROM U_DIM_FI_ACCOUNT B
                WHERE B.ACCOUNT_CODE = RFAU.ACCOUNT_CODE))
            LEVEL_7_NODE_NUM
                                                                      SYSDATE,
                                                                      'YYYY')
                                                                 + 1)))
             OR EXISTS
                   (SELECT 1
                      FROM TM1_FP_INACTIVE_ACCT_LOAD INAL
                     WHERE INAL.ACCOUNT_CODE = RFAU.ACCOUNT_CODE))
ORDER BY LEVEL_7_NODE_NUM, ACCOUNT_CODE
567,","
588,"."
589,
568,""""
570,
571,
569,0
592,0
599,1000
560,1
p_TargetDimension
561,1
2
590,1
p_TargetDimension,"FP Account"
637,1
p_TargetDimension,""
577,19
ACCOUNT_CODE
ACCOUNT_DESC
ACCOUNT_EFF_DATE
ACCOUNT_STATUS
LEVEL_7_NODE_NAME
LEVEL_6_NODE_NAME
LEVEL_5_NODE_NAME
LEVEL_4_NODE_NAME
LEVEL_3_NODE_NAME
LEVEL_2_NODE_NAME
LEVEL_1_NODE_NAME
LEVEL_7_NODE_DESC
LEVEL_6_NODE_DESC
LEVEL_5_NODE_DESC
LEVEL_4_NODE_DESC
LEVEL_3_NODE_DESC
LEVEL_2_NODE_DESC
LEVEL_1_NODE_DESC
LEVEL_7_NODE_NUM
578,19
2
2
2
2
2
2
2
2
2
2
2
2
2
2
2
2
2
2
1
579,19
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
580,19
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
581,19
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
582,19
VarType=32ColType=827
VarType=32ColType=827
VarType=32ColType=827
VarType=32ColType=827
VarType=32ColType=827
VarType=32ColType=827
VarType=32ColType=827
VarType=32ColType=827
VarType=32ColType=827

If(n_ParamErrors > 0);
  s_ParamErrors = NumberToString(n_ParamErrors);
  s_ErrorText = 'Required parameter values were not found.  Process terminating.';
  ASCIIOutput(s_LogFile, s_ErrorText);
  ExecuteCommand('CMD /C ECHO ' | s_MonitorCube | ',' | s_ProcessName | ',Prolog Error Count,' | s_ParamErrors | ',N >> ' | s_TIMonLog , 1);
  ExecuteCommand('CMD /C ECHO ' | s_MonitorCube | ',' | s_ProcessName | ',Status,' | 'ProcessQuit' | ',S >> ' | s_TIMonLog , 1);
  ExecuteCommand('CMD /C ECHO ' | s_MonitorCube | ',' | s_ProcessName | ',Comments,' | s_ErrorText | ',S >> ' | s_TIMonLog , 1);
  ProcessQuit;
EndIf;

############################################################################
## Add entry in the Chore Log for the TI Process start                                                                
############################################################################
s_DTS = TimSt(Now, '\d_\M_\Y_\h\i\s');
ExecuteCommand('CMD /C ECHO ' | s_DTS | ' process start : "' | s_ProcessName  | '" >> ' | s_ChoreLog ,1);


###########################################################################
## Get Minimum year to restrict data extraction from DW  ##
##########################################################################

### Lowest year available in the settings cube, this will allow the TI to limit the data set and load the current year only ####
## NH - 28/01/2014 - Altered min year to be 1 planning year back after discussions with AG.
p_CharSqlMinYear = numbertostring(cellgetn('FP Setting','3 Planning Year Back - Forecast','Num'));

############################################################################
##Attribute creation                                                                
############################################################################
# Create dimension the 1st time in
IF (DimensionExists(p_TargetDimension) = 0);
     DimensionCreate(p_TargetDimension);
ENDIF;

############################################################################
## Delete all elements in the dimension                                                                 
############################################################################
DimensionDeleteAllElements(p_TargetDimension);

### Must delete Tree Sort Seq attriubute & recreate it each time cause DATA section only populates it with the first if non-zero value 
AttrDelete(p_TargetDimension,'Tree Sort Seq');

### Delete description attr so that it appears next to the element in EDIT->ELEMENT->ATRRIBUTES screen
AttrDelete(p_TargetDimension,'Description');
AttrDelete(p_TargetDimension,'Account Code');
AttrDelete(p_TargetDimension,'Account Descr');
AttrDelete(p_TargetDimension, 'Account Status');
AttrDelete(p_TargetDimension,'Tree Sort Seq');
AttrDelete(p_TargetDimension,'Budget Description');
AttrDelete(p_TargetDimension,'Forecast Description');
Attrdelete(p_TargetDimension,'Locked Flag');

AttrInsert(p_TargetDimension, '', 'Tree Sort Seq', 'N');
AttrInsert(p_TargetDimension, '', 'Account Status', 'S');
AttrInsert(p_TargetDimension, '', 'Account Descr', 'S');
AttrInsert(p_TargetDimension, '', 'Account Code', 'S');
AttrInsert(p_TargetDimension,'','Description','A');
AttrInsert(p_TargetDimension,'','Forecast Description','A');
AttrInsert(p_TargetDimension,'','Budget Description','A');
AttrInsert(p_TargetDimension,'','Locked Flag','S');

####  Create a Level 0 Subset- ####
IF(SubsetExists(p_TargetDimension, 'Account L0') = 0);
  SubsetCreate(p_TargetDimension, 'Account L0');
ELSE;
  SubsetDeleteAllElements(p_TargetDimension, 'Account L0');
ENDIF;

DIMENSIONSORTORDER(p_TargetDimension,'ByInput','ASCENDING','ByInput','ASCENDING');



573,77

#****Begin: Generated Statements***
#****End: Generated Statements****

# Increment row counter
n_MetaDataTabRecordCounter = n_MetaDataTabRecordCounter + 1; 

DimensionElementInsert(p_TargetDimension,'',ACCOUNT_CODE,'n');

#  Do not create a consolidation level if node name is null. 
#  Levels 5  to 7 can have null Level Node Names but assume non-null node names for levels 1 to 3 from Business Process spec.
#  Level 4 will not be used
#
IF (LONG(LEVEL_7_NODE_NAME) <> 0);
   DimensionElementInsert(p_TargetDimension,'',LEVEL_7_NODE_NAME | ' L7','c');
   DimensionElementComponentAdd(p_TargetDimension,LEVEL_7_NODE_NAME | ' L7',ACCOUNT_CODE,1.000000);
ENDIF;

IF (LONG(LEVEL_6_NODE_NAME) <> 0);
   DimensionElementInsert(p_TargetDimension,'',LEVEL_6_NODE_NAME | ' L6','c');

    IF (LONG(LEVEL_7_NODE_NAME) <> 0);
       DimensionElementComponentAdd(p_TargetDimension,LEVEL_6_NODE_NAME | ' L6',LEVEL_7_NODE_NAME | ' L7',1.000000);

    ELSE;
       DimensionElementComponentAdd(p_TargetDimension,LEVEL_6_NODE_NAME | ' L6', ACCOUNT_CODE,1.000000); 
    ENDIF;
ENDIF;

IF (LONG(LEVEL_5_NODE_NAME) <> 0);
   DimensionElementInsert(p_TargetDimension,'',LEVEL_5_NODE_NAME | ' L5','c');

   IF (LONG(LEVEL_6_NODE_NAME) <> 0);
       DimensionElementComponentAdd(p_TargetDimension,LEVEL_5_NODE_NAME | ' L5',LEVEL_6_NODE_NAME | ' L6',1.000000);
   ELSE;

         IF (LONG(LEVEL_7_NODE_NAME) <> 0);
               DimensionElementComponentAdd(p_TargetDimension,LEVEL_5_NODE_NAME | ' L5', LEVEL_7_NODE_NAME | ' L7',1.000000);

         ELSE;
               DimensionElementComponentAdd(p_TargetDimension,LEVEL_5_NODE_NAME | ' L5', ACCOUNT_CODE,1.000000);  
         ENDIF;
   ENDIF;
   
ENDIF;

DimensionElementInsert(p_TargetDimension,'',LEVEL_3_NODE_NAME | ' L3','c');

IF (LONG(LEVEL_5_NODE_NAME) <> 0);
   DimensionElementComponentAdd(p_TargetDimension,LEVEL_3_NODE_NAME | ' L3',LEVEL_5_NODE_NAME | ' L5',1.000000);

ELSE;
   IF (LONG(LEVEL_6_NODE_NAME) <> 0);
       DimensionElementComponentAdd(p_TargetDimension,LEVEL_3_NODE_NAME | ' L3',LEVEL_6_NODE_NAME | ' L6',1.000000);
   ELSE;

         IF (LONG(LEVEL_7_NODE_NAME) <> 0);
               DimensionElementComponentAdd(p_TargetDimension,LEVEL_3_NODE_NAME | ' L3', LEVEL_7_NODE_NAME | ' L7',1.000000);

         ELSE;
               DimensionElementComponentAdd(p_TargetDimension,LEVEL_3_NODE_NAME | ' L3', ACCOUNT_CODE,1.000000);  
         ENDIF;
   ENDIF;

ENDIF;
  
# Level node names always non-null for level 1 to level 3

DimensionElementInsert(p_TargetDimension,'',LEVEL_2_NODE_NAME | ' L2','c');
DimensionElementComponentAdd(p_TargetDimension,LEVEL_2_NODE_NAME | ' L2',LEVEL_3_NODE_NAME | ' L3',1.000000);

DimensionElementInsert(p_TargetDimension,'',LEVEL_1_NODE_NAME | ' L1','c');
DimensionElementComponentAdd(p_TargetDimension,LEVEL_1_NODE_NAME | ' L1',LEVEL_2_NODE_NAME | ' L2',1.000000);

      


574,250

#****Begin: Generated Statements***
#****End: Generated Statements****

#########################################################################
#### Perform errror handling on the data
#########################################################################
n_DataErrors = 0; 

#### If error check finds issues, then this transaction record will be skipped
IF(n_DataErrors > 0); 
  ItemSkip; 
ENDIF; 


##*******************************************************************************************************************
##  Populate Description alias but note that Levels 5  to 7 may not exist in the unbalanced tree.
##  Also, must cater for duplicate names in descriptions in same row or in different rows because
##  alias name MUST be unique across a dimension.
##*******************************************************************************************************************
#
AttrPutS(LEVEL_1_NODE_DESC,p_TargetDimension,LEVEL_1_NODE_NAME | ' L1' ,'Description');
AttrPutS(LEVEL_1_NODE_DESC,p_TargetDimension,LEVEL_1_NODE_NAME | ' L1' ,'Forecast Description');
AttrPutS(LEVEL_1_NODE_DESC,p_TargetDimension,LEVEL_1_NODE_NAME | ' L1' ,'Budget Description');


IF (LEVEL_2_NODE_DESC @<> LEVEL_1_NODE_DESC);
    AttrPutS(LEVEL_2_NODE_DESC,p_TargetDimension,LEVEL_2_NODE_NAME | ' L2' ,'Description');
    AttrPutS(LEVEL_2_NODE_DESC,p_TargetDimension,LEVEL_2_NODE_NAME | ' L2' ,'Forecast Description');
    AttrPutS(LEVEL_2_NODE_DESC,p_TargetDimension,LEVEL_2_NODE_NAME | ' L2' ,'Budget Description');
   IF (LEVEL_5_NODE_DESC @<> LEVEL_3_NODE_DESC);
      AttrPutS(LEVEL_5_NODE_DESC,p_TargetDimension,LEVEL_5_NODE_NAME | ' L5','Description');
      AttrPutS(LEVEL_5_NODE_DESC,p_TargetDimension,LEVEL_5_NODE_NAME | ' L5','Forecast Description');
      AttrPutS(LEVEL_5_NODE_DESC,p_TargetDimension,LEVEL_5_NODE_NAME | ' L5','Budget Description');
   ELSE;

       AttrPutS(LEVEL_5_NODE_DESC |'.',p_TargetDimension,LEVEL_5_NODE_NAME | ' L5','Description');     
       AttrPutS(LEVEL_5_NODE_DESC |'.',p_TargetDimension,LEVEL_5_NODE_NAME | ' L5','Forecast Description');   
       AttrPutS(LEVEL_5_NODE_DESC |'.',p_TargetDimension,LEVEL_5_NODE_NAME | ' L5','Budget Description');   
   ENDIF;
ENDIF;

IF (LONG(LEVEL_6_NODE_NAME) <> 0);

    IF (LEVEL_6_NODE_DESC @<> LEVEL_5_NODE_DESC);

         # Current Liabilities & Current Assets have the same level 6 node description and must be catered for so that the alias' are unique
         #
         IF (LEVEL_3_NODE_DESC @= 'Current Liabilities'  & LEVEL_6_NODE_DESC @= 'Other Loans - Current');
                AttrPutS(LEVEL_6_NODE_DESC | '.',p_TargetDimension,LEVEL_6_NODE_NAME | ' L6','Description');
                AttrPutS(LEVEL_6_NODE_DESC | '.',p_TargetDimension,LEVEL_6_NODE_NAME | ' L6','Forecast Description');
                AttrPutS(LEVEL_6_NODE_DESC | '.',p_TargetDimension,LEVEL_6_NODE_NAME | ' L6','Budget Description');
        ELSE;
                AttrPutS(LEVEL_6_NODE_DESC,p_TargetDimension,LEVEL_6_NODE_NAME | ' L6','Description');
                AttrPutS(LEVEL_6_NODE_DESC,p_TargetDimension,LEVEL_6_NODE_NAME | ' L6','Forecast Description');
                AttrPutS(LEVEL_6_NODE_DESC,p_TargetDimension,LEVEL_6_NODE_NAME | ' L6','Budget Description');
        ENDIF;

   ELSE;
       AttrPutS(LEVEL_6_NODE_DESC |'.',p_TargetDimension,LEVEL_6_NODE_NAME | ' L6','Description');     
       AttrPutS(LEVEL_6_NODE_DESC |'.',p_TargetDimension,LEVEL_6_NODE_NAME | ' L6','Forecast Description');     
       AttrPutS(LEVEL_6_NODE_DESC |'.',p_TargetDimension,LEVEL_6_NODE_NAME | ' L6','Budget Description');     
   ENDIF;
ENDIF;


IF (LONG(LEVEL_7_NODE_NAME) <> 0);

   IF (LEVEL_7_NODE_DESC @<> LEVEL_6_NODE_DESC);
      AttrPutS(LEVEL_7_NODE_DESC,p_TargetDimension,LEVEL_7_NODE_NAME | ' L7','Description');
      AttrPutS(LEVEL_7_NODE_DESC,p_TargetDimension,LEVEL_7_NODE_NAME | ' L7','Forecast Description');
      AttrPutS(LEVEL_7_NODE_DESC,p_TargetDimension,LEVEL_7_NODE_NAME | ' L7','Budget Description');
   ELSE;

        IF (LEVEL_6_NODE_DESC @= LEVEL_5_NODE_DESC);
             AttrPutS(LEVEL_7_NODE_DESC | '..',p_TargetDimension,LEVEL_7_NODE_NAME | ' L7','Description');
             AttrPutS(LEVEL_7_NODE_DESC | '..',p_TargetDimension,LEVEL_7_NODE_NAME | ' L7','Forecast Description');
             AttrPutS(LEVEL_7_NODE_DESC | '..',p_TargetDimension,LEVEL_7_NODE_NAME | ' L7','Budget Description');
       ELSE;
             AttrPutS(LEVEL_7_NODE_DESC |'.',p_TargetDimension,LEVEL_7_NODE_NAME | ' L7','Description');        
             AttrPutS(LEVEL_7_NODE_DESC |'.',p_TargetDimension,LEVEL_7_NODE_NAME | ' L7','Forecast Description');    
             AttrPutS(LEVEL_7_NODE_DESC |'.',p_TargetDimension,LEVEL_7_NODE_NAME | ' L7','Budget Description');    
       ENDIF;
   ENDIF;
ENDIF;

## Get Locked Account Status
IF (DIMIX('FP Locked Account LKP', ACCOUNT_CODE) <> 0);
     sStatus = 'Locked-';
     s_AccountType = ATTRS('FP Locked Account LKP', ACCOUNT_CODE,'Account_Type');
     AttrPutS('Y',p_TargetDimension,ACCOUNT_CODE,'Locked Flag');
ELSE;
     sStatus = '';
     AttrPutS('N',p_TargetDimension,ACCOUNT_CODE,'Locked Flag');
ENDIF;

# Populate Budget Description

IF (ACCOUNT_STATUS @= 'A');
    AttrPutS(sStatus | ACCOUNT_CODE | '-' | ACCOUNT_DESC,p_TargetDimension,ACCOUNT_CODE,'Budget Description');
ELSE;
    AttrPutS(sStatus | 'Inactive-' |ACCOUNT_CODE | '-' | ACCOUNT_DESC,p_TargetDimension,ACCOUNT_CODE,'Budget Description');
ENDIF;

# Populate  Forecast Description

IF (ACCOUNT_STATUS @= 'A' );
      IF (DIMIX('FP Locked Account LKP', ACCOUNT_CODE) <> 0);
#              IF (s_AccountType @<> 'SMM');
                     IF (s_AccountType @<> 'FSB');
                          AttrPutS(sStatus | ACCOUNT_CODE | '-' | ACCOUNT_DESC,p_TargetDimension,ACCOUNT_CODE,'Forecast Description');
                        ELSE;
                            AttrPutS(ACCOUNT_CODE | '-' | ACCOUNT_DESC,p_TargetDimension,ACCOUNT_CODE,'Forecast Description');
                     ENDIF;
  #            ELSE;
  #               AttrPutS(ACCOUNT_CODE | '-' | ACCOUNT_DESC,p_TargetDimension,ACCOUNT_CODE,'Forecast Description');
  #            ENDIF;
      ELSEIF (sStatus @= '' & ACCOUNT_STATUS @= 'A');
            AttrPutS(ACCOUNT_CODE | '-' | ACCOUNT_DESC,p_TargetDimension,ACCOUNT_CODE,'Forecast Description');
     ENDIF;
ELSE;
    AttrPutS(sStatus | 'Inactive-' |ACCOUNT_CODE | '-' | ACCOUNT_DESC,p_TargetDimension,ACCOUNT_CODE,'Forecast Description');
ENDIF;

# Populate  Description - Status wont include any Locked descriptions and will be used for reporting

IF (ACCOUNT_STATUS @= 'A');
    AttrPutS(ACCOUNT_CODE | '-' | ACCOUNT_DESC,p_TargetDimension,ACCOUNT_CODE,'Description');
ELSE;
    AttrPutS('Inactive-' |ACCOUNT_CODE | '-' | ACCOUNT_DESC,p_TargetDimension,ACCOUNT_CODE,'Description');
ENDIF;


##*******************************************************************************************************************
##  Populate Account Status attribute. Only relevant at the account level (lowest level)
##*******************************************************************************************************************
#
IF (ACCOUNT_STATUS @= 'A');
    AttrPutS('Active',p_TargetDimension,ACCOUNT_CODE,'Account Status');
ELSE;
        AttrPutS('In Active',p_TargetDimension,ACCOUNT_CODE,'Account Status');
ENDIF;

##**********************************************************************************************************************
## Need to put the first seq number (Level_7_Node_Num) into all parent elements but not the leaf level 
##**********************************************************************************************************************
#
IF (ATTRN(p_TargetDimension, LEVEL_1_NODE_NAME | ' L1', 'Tree Sort Seq') = 0);
        AttrPutN(LEVEL_7_NODE_NUM, p_TargetDimension, LEVEL_1_NODE_NAME | ' L1' ,'Tree Sort Seq');
ENDIF;

IF (ATTRN(p_TargetDimension, LEVEL_2_NODE_NAME | ' L2', 'Tree Sort Seq') = 0);
        AttrPutN(LEVEL_7_NODE_NUM, p_TargetDimension, LEVEL_2_NODE_NAME | ' L2' ,'Tree Sort Seq');
ENDIF;

IF (ATTRN(p_TargetDimension, LEVEL_3_NODE_NAME | ' L3', 'Tree Sort Seq') = 0);
        AttrPutN(LEVEL_7_NODE_NUM, p_TargetDimension, LEVEL_3_NODE_NAME | ' L3' ,'Tree Sort Seq');
ENDIF;

#IF (ATTRN(p_TargetDimension, LEVEL_4_NODE_NAME | ' L4', 'Tree Sort Seq') = 0);
#        AttrPutN(LEVEL_7_NODE_NUM, p_TargetDimension, LEVEL_4_NODE_NAME | ' L4' ,'Tree Sort Seq');
#ENDIF;

# Levels 5 to 7 may not exist in the unbalanced tree
IF (LONG(LEVEL_5_NODE_NAME) <> 0);
 
    IF (ATTRN(p_TargetDimension, LEVEL_5_NODE_NAME | ' L5', 'Tree Sort Seq') = 0);
            AttrPutN(LEVEL_7_NODE_NUM, p_TargetDimension, LEVEL_5_NODE_NAME | ' L5' ,'Tree Sort Seq');
    ENDIF;

ENDIF;

IF (LONG(LEVEL_6_NODE_NAME) <> 0);

    IF (ATTRN(p_TargetDimension, LEVEL_6_NODE_NAME | ' L6', 'Tree Sort Seq') = 0);
          AttrPutN(LEVEL_7_NODE_NUM, p_TargetDimension, LEVEL_6_NODE_NAME | ' L6' ,'Tree Sort Seq');
    ENDIF;

ENDIF;

IF (LONG(LEVEL_7_NODE_NAME) <> 0);

    IF (attrn(p_TargetDimension, LEVEL_7_NODE_NAME | ' L7', 'Tree Sort Seq') = 0);
          AttrPutN(LEVEL_7_NODE_NUM, p_TargetDimension, LEVEL_7_NODE_NAME | ' L7' ,'Tree Sort Seq');
    ENDIF;

ENDIF;

##********************************************************************************************************************
##   Populate Subset L0 (Account Codes & no hierarchies)
##********************************************************************************************************************
#
SubsetElementInsert(p_TargetDimension, 'Account L0', ACCOUNT_CODE, 1);


575,49

#****Begin: Generated Statements***
#****End: Generated Statements****

###############################################################################
## Define Objects required for Epilog processing                                                                  
###############################################################################
If(n_ProcessBreak = 0);
  n_EndTime = Now;
  n_RunTime = n_EndTime - n_StartTime;
  s_RunTime = NumberToString(n_RunTime);
  s_EndTime = Date(n_EndTime, 1) | ' ' | TimSt(n_EndTime, '\h:\i:\s');
  s_ExecutionComment = If(MetaDataMinorErrorCount > 0 % DataMinorErrorCount > 0,
    'Process Execution Completed with Minor Errors (check log files for further details)',
    'Process Execution Completed Successfully');
  s_StartToEnd = 'Yes';
EndIf;

###############################################################################
## Add entry in the Chore Log for the TI Process end                                                                   
###############################################################################
s_DTS = TimSt(Now, '\d_\M_\Y_\h\i\s');
ExecuteCommand('CMD /C ECHO ' | s_DTS | ' process finish : "' | s_ProcessName  | '".  '
 | s_ExecutionComment | ' in ' | TimSt(n_RunTime, '\h hrs \i mins \s secs') | '. >> ' | s_ChoreLog ,1);

###############################################################################
## Write End Stats                                                                 
###############################################################################

ExecuteCommand('CMD /C ECHO ' | s_MonitorCube | ',' | s_ProcessName | ',Start,' | s_StartTime | ',S >> ' | s_TIMonLog , 1);
ExecuteCommand('CMD /C ECHO ' | s_MonitorCube | ',' | s_ProcessName | ',End,' | s_EndTime | ',S >> ' | s_TIMonLog , 1);

929,
907,
908,
904,0
905,0
909,0
911,
912,
913,
914,
915,
916,
917,0
918,1
919,0
920,50000
921,""
922,""
923,0
924,""
925,""
926,""
927,""
