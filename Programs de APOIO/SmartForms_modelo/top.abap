*&*********************************************************************
*& Tipos
*&*********************************************************************
TYPES: BEGIN OF typ_t_out,
*        CheckBox
        checkbox    TYPE abap_bool,

*       Informa��es do Fornecedor
        NOME        TYPE /dhpb/t_0003-NOME,
        cnpj        TYPE /DHPB/T_0001-cnpj,
        email       TYPE /DHPB/T_0001-email,
        PERIODO     TYPE /DHPB/T_0003-PERIODO,

*       Nota Fiscal
        nm_empresa  TYPE /DHPB/T_0001-nm_empresa,
        endereco    TYPE /DHPB/T_0001-endereco,

*       servi�os realizados
        hora_a      TYPE  /DHPB/T_0003-hora_a,
        hora_b      TYPE  /DHPB/T_0003-hora_b,

*       outros
        vl_hora     TYPE /DHPB/T_0002-VL_HORA,
        VT_HORA     TYPE DEC5_2,
        apt_hora    TYPE DEC5_2,
       END OF typ_t_out.

*&*********************************************************************
*& Transpantes
*&*********************************************************************
* Tabelas Transparentes
TABLES sscrfields.
* Tabelas Internar
DATA: gt_T_out TYPE TABLE OF typ_t_out.
* Estruturas
DATA: gs_T_out TYPE typ_t_out.

**********************************************************************
* Vari�vels
**********************************************************************

* Parametros de dados do Smartform
DATA: NM_EMPRESA TYPE NAME1_GP,
      CNPJ       TYPE STCD3,
      EMAIL      TYPE AD_SMTPADR,
      PERIODO    TYPE /DHPB/EVENTO_PERAPUR.


* Vari�veis da Module Pool
DATA: p_codigo  TYPE /DHPB/T_0001-CODIGO,  "OBLIGATORY, "C�digo do Recurso
      p_periodo TYPE /DHPB/T_0003-PERIODO. "OBLIGATORY. "Periodo.
