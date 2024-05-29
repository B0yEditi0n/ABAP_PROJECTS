CLASS cl_model DEFINITION.
  PUBLIC SECTION.
    METHODS: get_dados,
             prepare_mail,
             check_box_click IMPORTING row TYPE int4.

  PRIVATE SECTION.
* Variáveis de importação da smartform
    DATA: lt_smartform_name       TYPE tdsfname.
    DATA: lt_control_parameters   TYPE ssfctrlop,
          lt_output_option        TYPE ssfcompop.

    DATA: lv_default_print TYPE rspoptype,
          lv_output_inf    TYPE ssfcrescl,
          lt_pdffile       TYPE STANDARD TABLE OF tline.


    METHODS:  get_sf_name,
              creat_smartform,
              get_default_print,
              print_opt,
              sum_working_day
                IMPORTING c_date      TYPE datum
                          n_days      TYPE int4
                EXPORTING working_day TYPE datum,
              check_is_payday
                IMPORTING c_date      TYPE datum
                EXPORTING working_day TYPE datum,
              send_email
                IMPORTING lv_dest_mail TYPE ad_smtpadr
                          lv_file_size TYPE so_obj_len
                          binary_cont  TYPE solix_tab
                          periodo      TYPE /dhpb/evento_perapur.

ENDCLASS.

CLASS cl_model IMPLEMENTATION.

  METHOD check_box_click.
    READ TABLE gt_t_out INTO gs_t_out INDEX row.

    IF gs_t_out-checkbox >= 'X'.
      gs_t_out-checkbox = ' '.
    ELSE.
      gs_t_out-checkbox = 'X'.
    ENDIF.

    MODIFY gt_t_out FROM gs_t_out INDEX row.
  ENDMETHOD. " check_box_click

*&*********************************************************************
*& Sessão Privada
*&*********************************************************************
  METHOD prepare_mail.
*    CHECK gt_t_out is INITIAL.
    me->get_default_print( ).
    me->get_sf_name( ).
    me->print_opt( ).

    me->creat_smartform( ).

  ENDMETHOD. " end_of_selection

  METHOD get_dados.
    DATA: lv_gt_table TYPE TABLE OF typ_t_out.
    CLEAR: gs_t_out,
           gt_t_out.


    SELECT t1~nome,
           t1~cnpj,
           t1~email,
           t3~periodo,

           t1~nm_empresa,
           t1~endereco,

           t3~hora_a,
           t3~hora_b,
           t2~vl_hora
      FROM /dhpb/t_0002 AS t2
      INNER JOIN /dhpb/t_0001 AS t1 ON t1~cod_niv_tec = t2~cod_niv_tec
      INNER JOIN /dhpb/t_0003 AS t3 ON t3~codigo      = t1~codigo


      WHERE t1~codigo  = @p_codigo
        AND t3~periodo = @p_periodo
      INTO CORRESPONDING FIELDS OF TABLE @lv_gt_table.
    .
    LOOP AT lv_gt_table INTO gs_t_out.
*&      Preenchimento da Checkbox
      gs_t_out-checkbox = 'X'.

*&      Processamento da hora total
      gs_t_out-vt_hora  = gs_t_out-hora_a * gs_t_out-vl_hora.
      gs_t_out-apt_hora = gs_t_out-hora_a * gs_t_out-vl_hora.

      APPEND gs_t_out TO gt_t_out.

    ENDLOOP.

  ENDMETHOD. "get_dados

  METHOD get_sf_name.

    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
      EXPORTING
        formname = '/DHPB/AV_001'
      IMPORTING
        fm_name  = me->lt_smartform_name.

  ENDMETHOD. " get_sf_name

  METHOD creat_smartform.
    CLEAR gs_t_out.
*   Variáveis do PDF
    DATA: lv_file_size      TYPE so_obj_len,
          lv_file_sizex     TYPE xstring,
          lt_binary_content TYPE solix_tab.

    LOOP AT gt_t_out INTO gs_t_out.
      IF gs_t_out-checkbox = 'X'.


        CALL FUNCTION me->lt_smartform_name
          EXPORTING
            control_parameters = me->lt_control_parameters
            output_options     = me->lt_output_option
            nm_empresa         = gs_t_out-nm_empresa
            cnpj               = gs_t_out-cnpj
            email              = gs_t_out-email
            periodo            = gs_t_out-periodo
            name               = gs_t_out-nome
            endereco           = gs_t_out-endereco
            apt_horas          = gs_t_out-apt_hora
            total_mes          = gs_t_out-vt_hora
*           irrf               = -irrf
*           csll               = -csll
*           pis                = -pis
*           cofins             = -cofins
            valor_liquido      = gs_t_out-vt_hora
            hora_a             = gs_t_out-hora_a
            hora_b             = gs_t_out-hora_b
          IMPORTING
            job_output_info    = me->lv_output_inf.

        IF sy-subrc <> 0.
        ENDIF.

        CALL FUNCTION 'CONVERT_OTF'
          EXPORTING
            format       = 'PDF'
            pdf_preview  = 'X'
          IMPORTING
            bin_filesize = lv_file_size
            bin_file     = lv_file_sizex
          TABLES
            otf          = me->lv_output_inf-otfdata
            lines        = me->lt_pdffile.
        IF sy-subrc <> 0.
        ENDIF.

        CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
          EXPORTING
            buffer     = lv_file_sizex
          TABLES
            binary_tab = lt_binary_content.

*        Chamar a função de envio de email
        me->send_email( lv_dest_mail = gs_t_out-email
                        lv_file_size = lv_file_size
                        binary_cont  = lt_binary_content
                        periodo      = gs_t_out-periodo
                      ).

      ENDIF.
    ENDLOOP.

  ENDMETHOD. " creat_smartForm

  METHOD get_default_print.

    CALL FUNCTION 'SSF_GET_DEVICE_TYPE'
      EXPORTING
        i_language    = sy-langu
        i_application = 'SAPDEFAULT'
      IMPORTING
        e_devtype     = me->lv_default_print.

    IF sy-subrc <> 0.
    ENDIF.

  ENDMETHOD. " get_default_print

  METHOD print_opt.
    me->lt_control_parameters-preview   = 'X'.
    me->lt_control_parameters-no_dialog = 'X'.
    me->lt_control_parameters-getotf    = 'X'.  "Gera o Formato OTF do sap

    me->lt_output_option-tddest         = 'X'.
    me->lt_output_option-tdprinter      = me->lv_default_print.

  ENDMETHOD. " print_opt

  METHOD sum_working_day.
    DATA lv_week_day             TYPE p.
    DATA lv_is_HOLIDAY           TYPE C.
    DATA lv_temp_date            TYPE datum.
    working_day = c_date - 1.

    DATA: i TYPE int4.
    i = 0.

    WHILE n_days >= i.
      working_day = working_day + 1.
       CALL FUNCTION 'HOLIDAY_CHECK_AND_GET_INFO' " Checa se o dia é Feriado
         EXPORTING
           date                               = working_day
           holiday_calendar_id                = 'BR'
        IMPORTING
           holiday_found                       = lv_is_holiday.

      CALL FUNCTION 'DAY_IN_WEEK' " Checa o Dia da Semana
        EXPORTING
          datum         = working_day
       IMPORTING
         WOTNR         = lv_week_day.


       IF lv_is_holiday = ' ' AND lv_week_day <> 6 AND lv_week_day <> 7. " 6 sabado 7 domingo
         i = i + 1.
       ENDIF.


    ENDWHILE.


  ENDMETHOD. " sum_working_day

  METHOD check_is_payday.
    DATA: lv_is_holiday  TYPE c,
          lv_week_day    TYPE p.

    DATA: vl_is_workday  TYPE abap_bool.

    working_day    = c_date.
    vl_is_workday  = ' '.

    WHILE vl_is_workday = ' '.
      CALL FUNCTION 'HOLIDAY_CHECK_AND_GET_INFO' " Checa se o dia é Feriado
           EXPORTING
             date                               = working_day
             holiday_calendar_id                = 'BR'
          IMPORTING
             holiday_found                       = lv_is_holiday.

      CALL FUNCTION 'DAY_IN_WEEK' " Checa o Dia da Semana
           EXPORTING
             datum         = working_day
           IMPORTING
             WOTNR         = lv_week_day.

      IF lv_week_day = 6 or lv_week_day = 7 or lv_is_holiday = 'X'.
        vl_is_workday = ' '.
        working_day = working_day + 1.
      ELSE.
        vl_is_workday = 'X'.
      ENDIF.
    ENDWHILE.
  ENDMETHOD. " check_is_payday

  METHOD send_email.
    DATA: send_request  TYPE REF TO cl_bcs,
*         mailsubject type so_obj_des,
          mailtext      TYPE bcsy_text,
          document      TYPE REF TO cl_document_bcs,
          sender        TYPE REF TO cl_cam_address_bcs,
          recipient_to  TYPE REF TO cl_cam_address_bcs,
          recipient_cc  TYPE REF TO cl_cam_address_bcs,
          recipient_bcc TYPE REF TO cl_cam_address_bcs,
          bcs_exception TYPE REF TO cx_bcs.

*   variável para soma de dias uteis
    DATA: vl_tmp_data     TYPE datum,
          vl_five_workday TYPE datum,
          vl_payday       TYPE datum,
          vl_invoiceday   TYPE datum.

    send_request = cl_bcs=>create_persistent( ). " Transação majoritária que conter todo o pacote email



    vl_tmp_data = |{ periodo }01|.
    vl_tmp_data+4(2) = vl_tmp_data+4(2) + 1.

    me->sum_working_day( EXPORTING
                            c_date = vl_tmp_data
                            n_days = 6
                          IMPORTING
                            working_day = vl_five_workday
     ).
    vl_tmp_data = |{ vl_tmp_data(6) }15|.
    me->check_is_payday( EXPORTING
                            c_date = vl_tmp_data
                          IMPORTING
                            working_day = vl_payday
     ).
    vl_tmp_data = |{ vl_tmp_data(6) }22|.
    me->check_is_payday( EXPORTING
                          c_date = vl_tmp_data
                         IMPORTING
                          working_day = vl_invoiceday
     ).


*   mensagem
    DATA(vl_txt_fiveworkday) = |{ vl_five_workday+6 }/{ vl_five_workday+4(2) }/{ vl_five_workday(4) }|.
    DATA(vl_txt_payday)      = |{ vl_payday+6 }/{ vl_payday+4(2) }/{ vl_payday(4) } |.
    DATA(vl_txt_invoiceday)  = |{ vl_invoiceday+6 }/{ vl_invoiceday+4(2) }/{ vl_invoiceday(4) }|.

    APPEND 'Bom dia!' TO mailtext.
*    colocar periodo do mes atual
    APPEND |Segue Extrato de Serviços Prestados referente às horas aprovadas do período de { periodo+4 }/{ periodo(4) } para geração de sua nota fiscal.| TO mailtext.
*    Proximo mes do período
*    7 dia Util do mes / dia 15 do mes e se for não ultil o proximo dia util / 7 dias uteis apos o dia do pagamento
    APPEND |Lembramos que o prazo final de nosso recebimento será { vl_txt_fiveworkday }, para pagamento em { vl_txt_payday }. As notas enviadas após esta data serão programadas para pagamento somente no dia { vl_txt_invoiceday }.| TO mailtext.
    APPEND '•       A nota fiscal deve ser enviada exclusivamente no e-mail : ' TO mailtext.
    APPEND 'contato@dhconsulting.com.br; diogenes.henrique@dhconsulting.com.br.' TO mailtext.

*   Criação do Email
    document = cl_document_bcs=>create_document(
     i_type = 'RAW'
     i_text = mailtext
     i_subject = |Fechamento de { periodo } - Extrato de Serviços Prestados|
    ).

*   Adicionando anexo no Email
    CALL METHOD document->add_attachment
      EXPORTING
        i_attachment_type    = 'PDF'
        i_attachment_subject = |Anexo VPS - { periodo+4(2) }.{ periodo(4) }|
        i_attachment_size    = lv_file_size
        i_att_content_hex    = binary_cont.

    send_request->set_document( document ).

*   Adicionar Emissor
    sender = cl_cam_address_bcs=>create_internet_address( 'contato@dhconsulting.com.br' ).
    send_request->set_sender( sender ).

*   Adicionar Destinátario
    recipient_to = cl_cam_address_bcs=>create_internet_address( lv_dest_mail ).
    send_request->add_recipient( i_recipient = recipient_to ).

*&   Finalizar Processo de Envio
    DATA(lv_sent_to_all) = send_request->send( ).
    IF lv_sent_to_all = 'X'.
      MESSAGE 'Email enviados para destinatarios' TYPE 'I'.
    ELSE.
      MESSAGE '@@ O Email não pode ser enviado aos destinatarios' TYPE 'I'.
    ENDIF.
    COMMIT WORK.

  ENDMETHOD. " send_email

ENDCLASS.
