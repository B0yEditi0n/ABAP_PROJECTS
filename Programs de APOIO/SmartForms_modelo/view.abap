CLASS cl_view DEFINITION.

  PUBLIC SECTION.
    DATA: cl_model TYPE REF TO cl_model,
          OK_CODE  LIKE SY-UCOMM.


    METHODS: constructor,
             initialization,
             inputuser IMPORTING u_command TYPE char70.

  PRIVATE SECTION.
    DATA: cl_salv_alv   TYPE REF TO cl_salv_table,
          cl_salv_funct TYPE REF TO cl_salv_functions_list.

    DATA exclude type standard table of sy-ucomm.

    METHODS: alv_display,
             set_toolbar,
             field_cat IMPORTING
                        vl_name     TYPE char30
                        vl_short    TYPE char10
                        vl_med      TYPE char20
                        vl_long     TYPE char40
                        vl_visible  TYPE abap_bool,
             fieldcat_Checkbox,
             cb_event FOR EVENT link_click OF cl_salv_events_table
              IMPORTING row
                        column,
             process_email FOR EVENT ADDED_FUNCTION OF CL_SALV_EVENTS.
             .

ENDCLASS.

CLASS cl_view IMPLEMENTATION.
  METHOD constructor.
    CREATE OBJECT me->cl_model.
  ENDMETHOD. " Constructor

  METHOD initialization.
    CALL SCREEN 1002.
  ENDMETHOD. " initialization

  METHOD inputuser.
    if sy-dynnr = '1002'.
    CASE u_command.
      WHEN 'CANCEL'.
        LEAVE PROGRAM.
      WHEN 'BACK'.
        LEAVE TO SCREEN 0.
      WHEN 'RUN'.
        if p_codigo = 0 or p_periodo = 0.
          MESSAGE 'Preencha todos os campos' TYPE 'S'.
        ELSE.
          me->cl_model->get_dados( ).
          me->alv_display( ).
        ENDIF.

      WHEN 'TCV'.
        set PARAMETER ID 'DTB' FIELD '/DHPB/T_0002'.
        CALL TRANSACTION 'SE16' AND SKIP FIRST SCREEN.
      WHEN 'TCR'.
        set PARAMETER ID 'DTB' FIELD '/DHPB/T_0001'.
        CALL TRANSACTION 'SE16' AND SKIP FIRST SCREEN.
      WHEN 'THM'.
        set PARAMETER ID 'DTB' FIELD '/DHPB/T_0003'.
        CALL TRANSACTION 'SE16' AND SKIP FIRST SCREEN.

    ENDCASE.
    ENDIF.
  ENDMETHOD. " inputuser

**********************************************************************
* Sess�o Privada
**********************************************************************
  METHOD alv_display.
    DATA: cl_event_handler TYPE REF TO cl_salv_events_table.

    CALL METHOD cl_salv_table=>factory
      IMPORTING
        r_salv_table   = me->cl_salv_alv
      CHANGING
        t_table        = gt_t_out.

     me->fieldcat_Checkbox( ).
     me->field_cat( vl_name = 'NOME'        vl_visible = 'X'  vl_short = 'Nome' VL_MED = 'Nome do Recurso' vl_long = 'Nome do Recurso').
     me->field_cat( vl_name = 'CNPJ'        vl_visible = ' '  vl_short = ''  VL_MED = '' vl_long = '').
     me->field_cat( vl_name = 'EMAIL'       vl_visible = ' '  vl_short = ''  VL_MED = '' vl_long = '').
     me->field_cat( vl_name = 'PERIODO'     vl_visible = 'X'  vl_short = 'Per�odo'  VL_MED = 'Per�odo' vl_long = 'Per�odo').
     me->field_cat( vl_name = 'NM_EMPRESA'  vl_visible = ' '  vl_short = ''  VL_MED = '' vl_long = '').
     me->field_cat( vl_name = 'ENDERECO'    vl_visible = ' '  vl_short = ''  VL_MED = '' vl_long = '').
     me->field_cat( vl_name = 'HORA_A'      vl_visible = 'X'  vl_short = 'Horas_a'  VL_MED = 'Horas Aprovadas' vl_long = 'Horas Aprovadas').
     me->field_cat( vl_name = 'HORA_B'      vl_visible = ' '  vl_short = ''  VL_MED = '' vl_long = '').
     me->field_cat( vl_name = 'VL_HORA'     vl_visible = 'X'  vl_short = 'VL Hora'  VL_MED = 'Valor Hora' vl_long = 'Valor Hora').
     me->field_cat( vl_name = 'VT_HORA'     vl_visible = 'X'  vl_short = 'Valor_T'  VL_MED = 'Valor Total do M�s' vl_long = 'Valor Total do M�s').
     me->field_cat( vl_name = 'APT_HORA'     vl_visible = ''  vl_short = ''  VL_MED = '' vl_long = '').

     me->set_toolbar( ).

     cl_event_handler = me->cl_salv_alv->get_event( ).

     SET HANDLER me->cb_event FOR cl_event_handler.
     SET HANDLER me->process_email FOR cl_event_handler.


     cl_salv_alv->display( ).
  ENDMETHOD. " alv_display

  METHOD set_toolbar.
    me->cl_salv_alv->SET_SCREEN_STATUS(
     PFSTATUS      =  'BAR_MAIL'
     REPORT       = SY-REPID
     SET_FUNCTIONS = me->cl_salv_alv->C_FUNCTIONS_ALL ).
  ENDMETHOD. " set_toolbar

  METHOD field_cat.
    DATA: lv_columns TYPE REF TO cl_salv_columns_table,
          lv_column TYPE REF TO cl_salv_column.

    lv_columns = me->cl_salv_alv->get_columns( ).
    lv_columns->set_optimize( 'X' ).
    lv_column = lv_columns->get_column( VL_NAME ).
    lv_column->set_visible( vl_visible ).
    lv_column->set_short_text( VL_SHORT ).
    lv_column->SET_MEDIUM_TEXT( VL_MED ).
    lv_column->set_long_text( vl_long ).

  ENDMETHOD. " field_Cat

  METHOD fieldcat_Checkbox.

    DATA lv_columns TYPE REF TO cl_salv_columns_table.
    DATA lv_column TYPE REF TO  cl_salv_column_table.
    DATA cl_salv_functions TYPE REF TO cl_salv_functions.

    cl_salv_functions = me->cl_salv_alv->get_functions( ).
    cl_salv_functions->set_all( abap_true ).

    lv_columns = me->cl_salv_alv->get_columns( ).
    lv_columns->set_optimize( 'X' ).

    lv_column ?= lv_columns->get_column( 'CHECKBOX' ).
    lv_column->set_visible( 'X' ).
    lv_column->set_short_text( 'Enviar?' ).
    lv_column->SET_MEDIUM_TEXT( 'Enviar para?' ).
    lv_column->set_long_text( 'Enviar documento para?' ).

    lv_column->set_cell_type( if_salv_c_cell_type=>checkbox_hotspot ).
*    lv_column->set_cell_type( if_salv_c_cell_type=>checkbox ). " Para checkbox desabilitada
    lv_column->set_output_length( 10 ).

  ENDMETHOD. " fieldcat_Checkbox

  METHOD cb_event.
    if column = 'CHECKBOX'.
      cl_model->check_box_click( row ).
      me->cl_salv_alv->refresh( ).
      cl_gui_cfw=>flush( ).
    ENDIF.
  ENDMETHOD. " cb_event

  METHOD process_email.
    me->cl_model->prepare_mail( ).
  ENDMETHOD. " process_email
ENDCLASS.
