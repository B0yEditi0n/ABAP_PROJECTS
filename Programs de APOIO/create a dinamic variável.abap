*&---------------------------------------------------------------------*
*& Report  YCAS_XML
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ycas_xml.

*----------------------------------------------------------------------*
*       CLASS cl_define_type DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS cl_define_type DEFINITION.
* DATA: o_itab  TYPE REF TO cl_abap_tabledescr,
*       o_struc TYPE REF TO cl_abap_structdescr,
*       o_type  TYPE REF TO cl_abap_typedescr,
*       o_data  TYPE REF TO cl_abap_datadescr.

  PUBLIC SECTION.

    TYPES: BEGIN OF ty_define_type,
            name TYPE dd04d-rollname,
            type TYPE dd04d-domname,
           END OF ty_define_type,
           ty_t_define_type TYPE TABLE OF ty_define_type,
           BEGIN OF ty_input_data,
             name  TYPE dd04d-rollname,
             value TYPE string,
           END OF ty_input_data,
           ty_t_input_data TYPE TABLE OF ty_input_data.
    METHODS:
      create_type
        IMPORTING lv_type TYPE dd04d-domname
                  lv_value TYPE string OPTIONAL
        RETURNING value(o_variavel) TYPE REF TO data,

      create_struture
        IMPORTING lt_type TYPE ty_t_define_type
          RETURNING value(o_variavel) TYPE REF TO data,

      create_table
        IMPORTING lt_type TYPE ty_t_define_type
        RETURNING value(o_variavel) TYPE REF TO data,

      input_table
        IMPORTING lt_data    TYPE ty_t_input_data
                  o_table   TYPE REF TO data
        EXPORTING o_e_table TYPE REF TO data.


ENDCLASS.                    "cl_define_type DEFINITION

*----------------------------------------------------------------------*
*       CLASS cl_define_type IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS cl_define_type IMPLEMENTATION.
  METHOD create_type.
*     Objetos de manipulação de Estrtura
    DATA: o_data_type TYPE REF TO cl_abap_datadescr.

    DATA: lt_dfies TYPE TABLE OF dfies,
          lt_comp TYPE abap_component_tab.

    DATA: lv_create TYPE REF TO data.
    FIELD-SYMBOLS <fs_data> TYPE ANY.

    o_data_type ?= cl_abap_typedescr=>describe_by_name( lv_type ).

    CREATE DATA lv_create TYPE HANDLE o_data_type.
    ASSIGN lv_create->* TO <fs_data>.

    IF lv_value IS NOT INITIAL.
      <fs_data> = lv_value.
    ENDIF.

    o_variavel = lv_create.

  ENDMETHOD.                    "create_type

  METHOD create_struture.
*    DATA: stry TYPE REF TO cl_abap_structdescr.
    DATA: o_data_type TYPE REF TO cl_abap_datadescr.
    DATA: lt_type_ref	TYPE abap_component_tab,
          ls_type_ref	TYPE abap_componentdescr.

    DATA: ls_type TYPE ty_define_type.
    DATA: lv_create TYPE REF TO data.

    LOOP AT lt_type INTO ls_type.
      ls_type_ref-name       = ls_type-name.
      ls_type_ref-type       ?= cl_abap_typedescr=>describe_by_name( ls_type-type ).
      APPEND ls_type_ref TO lt_type_ref.
    ENDLOOP.

    o_data_type = cl_abap_structdescr=>create( lt_type_ref ).

    CREATE DATA lv_create TYPE HANDLE o_data_type.

    o_variavel = lv_create.

  ENDMETHOD.                    "create_struture

  METHOD create_table.
    DATA: o_type_stu TYPE REF TO cl_abap_datadescr,
          o_type_tab TYPE REF TO cl_abap_datadescr.
    DATA: lt_type_ref	TYPE abap_component_tab,
          ls_type_ref	TYPE abap_componentdescr.

    DATA: ls_type TYPE ty_define_type.
    DATA: lv_create TYPE REF TO data.
    LOOP AT lt_type INTO ls_type.
      ls_type_ref-name       = ls_type-name.
      ls_type_ref-type       ?= cl_abap_typedescr=>describe_by_name( ls_type-type ).
      APPEND ls_type_ref TO lt_type_ref.
    ENDLOOP.


    o_type_stu = cl_abap_structdescr=>create( lt_type_ref ).
    o_type_tab = cl_abap_tabledescr=>create( o_type_stu ).

    CREATE DATA lv_create TYPE HANDLE o_type_tab.

    o_variavel = lv_create.
  ENDMETHOD.                    "create_table

  METHOD input_table.
    DATA: ls_data TYPE ty_input_data.

    FIELD-SYMBOLS:  <fs_table> TYPE table,
                    <fs_line>  TYPE ANY,
                    <fs_field> TYPE ANY.
    " appenda na linha
    CHECK o_table IS NOT INITIAL.
    ASSIGN o_table->* TO <fs_table>.
    APPEND INITIAL LINE TO <fs_table> ASSIGNING <fs_line>.
    LOOP AT lt_data INTO ls_data.
      ASSIGN COMPONENT ls_data-name OF STRUCTURE <fs_line> TO <fs_field>.
      IF <fs_field> IS ASSIGNED.
        <fs_field> = ls_data-value.
      ENDIF.
    ENDLOOP.
    o_e_table = o_table.
  ENDMETHOD.                    "input_table

ENDCLASS.                    "cl_define_type IMPLEMENTATION

INITIALIZATION.
  " Variáveis de Definição de Tipo
  DATA: o_methdo TYPE REF TO cl_define_type.
  DATA: lt_type TYPE TABLE OF cl_define_type=>ty_define_type,
        ls_type TYPE cl_define_type=>ty_define_type.

  " Variáveis de Preenchimento de Tabela
  DATA: lt_data TYPE cl_define_type=>ty_t_input_data,
        ls_data TYPE cl_define_type=>ty_input_data.
  " Variável de Recebimento de tipo
  DATA: o_data TYPE REF TO data.

  CREATE OBJECT o_methdo.

* CRIAÇÃO DE VARIAVEL SIMPLES
  o_data = o_methdo->create_type(
    lv_type   = 'STRING'
    lv_value  = 'String Alocada'
  ).

  o_data = o_methdo->create_type(
    lv_type   = 'INT4'
    lv_value  = '10'
  ).

* CRIAçãO DE ESTRUTURA
  ls_type-name = 'NOME'.
  ls_type-type = 'STRING'.
  APPEND ls_type TO lt_type.

  ls_type-name = 'IDADE'.
  ls_type-type = 'INT4'.
  APPEND ls_type TO lt_type.

  o_data = o_methdo->create_struture( lt_type ).

* CRIAçãO DE TABELA usando o mesmo tipo
  o_data = o_methdo->create_table( lt_type ).

*  Preenchimento do código
  ls_data-name  = 'NOME'.
  ls_data-value = 'Seveenteen'.
  APPEND ls_data TO lt_data.

  ls_data-name  = 'IDADE'.
  ls_data-value = '498'.
  APPEND ls_data TO lt_data.

  o_methdo->input_table(
    EXPORTING lt_data    = lt_data
              o_table   = o_data
    IMPORTING o_e_table = o_data
  ).
