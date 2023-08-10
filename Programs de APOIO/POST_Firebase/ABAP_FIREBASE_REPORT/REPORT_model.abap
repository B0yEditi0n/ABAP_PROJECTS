CLASS cl_model DEFINITION.
  PUBLIC SECTION.
    METHODS: at_seletion_screen.
  PRIVATE SECTION.
    METHODS: get_host_ip RETURNING VALUE(lv_url) TYPE string,
             select_data_api,
             post_data_api,
             put_data_api,
             delet_data_api.
ENDCLASS.

CLASS cl_model IMPLEMENTATION.
  METHOD at_seletion_screen.
    IF     p_bt_get = 'X'.
      select_data_api( ).
    ELSEIF p_bt_pos = 'X'.
      post_data_api( ).
    ELSEIF p_bt_put = 'X'.
      put_data_api( ).
    ELSEIF p_bt_del = 'X'.
      delet_data_api( ).
    ENDIF.

  ENDMETHOD.

  "##################
  "# SESSÃO PRIVADA #
  "##################

  METHOD get_host_ip.
    DATA: lv_ipv4 TYPE MSXXLIST-HOSTADR,
          lv_ipv6 TYPE NI_NODEADDR.

    DATA: lv_path TYPE string.
    DATA(lv_port) = 5723.

    IF p_path IS NOT INITIAL.
      lv_path = |{ p_path }|.
    ENDIF.

    CALL FUNCTION 'TH_USER_INFO'
      IMPORTING
        HOSTADDR     = lv_ipv4
        ADDRSTR      = lv_ipv6.

    lv_url = |http://{ lv_ipv6 }:{ lv_port }{ lv_path }|.


  ENDMETHOD.

  METHOD select_data_api.
    DATA(lv_url) = get_host_ip( ).

    CL_HTTP_CLIENT=>CREATE_BY_URL(
      EXPORTING
        URL           = |{ lv_url }|
        ssl_id        = 'ANONYM'
      IMPORTING
        CLIENT = DATA(CL_CLIENT)
      EXCEPTIONS
        argument_not_found = 1
        plugin_not_active  = 2
        internal_error     = 3
      ).

    CHECK cl_client IS BOUND.

    CL_CLIENT->SEND(
        EXCEPTIONS
          http_communication_failure = 1
          http_invalid_state         = 2
    ).

    IF sy-subrc IS NOT INITIAL.
      MESSAGE |Erro no send, sy-subrc| TYPE 'S'.
      CHECK sy-subrc = 0.
    ENDIF.

    CL_CLIENT->receive(
      EXCEPTIONS
        HTTP_COMMUNICATION_FAILURE = 1 " erro está caindo aqui
        HTTP_INVALID_STATE         = 2
        HTTP_PROCESSING_FAILED     = 3
*        HTTP_INVALID_TIMEOUT       = 4
        OTHERS                     = 5
   ).
    IF sy-subrc is not initial.
      cl_client->close( ).
      MESSAGE |Erro de Conexão, { sy-subrc }| TYPE 'S'.
      CHECK sy-subrc = 0.
    ENDIF.

    CL_CLIENT->response->get_status(
      IMPORTING
        code   = DATA(lv_status_code)
        reason = DATA(lv_status_reason)
    ).

    gv_json_get_data = cl_client->response->get_cdata( ).

    cl_client->close( ).

  ENDMETHOD.

  METHOD post_data_api.
    DATA(lv_url) = get_host_ip( ).
    CL_HTTP_CLIENT=>CREATE_BY_URL(
        EXPORTING
          URL           = lv_url
          ssl_id        = 'ANONYM'
        IMPORTING
          CLIENT = DATA(CL_CLIENT)
        EXCEPTIONS
          argument_not_found = 1
          plugin_not_active  = 2
          internal_error     = 3
      ).

    CHECK CL_CLIENT IS BOUND.

    DATA(lv_json) = CONV string( p_post_j ).

    " Define a conexão como POST
    cl_client->request->set_method( 'POST' ).

    " Define o tipo de Arquivo upado
    cl_client->request->if_http_entity~set_content_type(
      EXPORTING
        CONTENT_TYPE = IF_REST_MEDIA_TYPE=>GC_APPL_JSON
    ).

    " Metodo do POST
    cl_client->request->append_cdata( data = lv_json ).

    cl_client->send(
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3
        OTHERS                     = 4 ).

    CHECK sy-subrc = 0.

    cl_client->receive(
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3
        OTHERS                     = 4 ).

    gv_json_get_data = cl_client->response->get_cdata( ).

    cl_client->close( ).

  ENDMETHOD.

  METHOD put_data_api.
    DATA(lv_url) = get_host_ip( ).
    CL_HTTP_CLIENT=>CREATE_BY_URL(
        EXPORTING
          URL           = lv_url
          ssl_id        = 'ANONYM'
        IMPORTING
          CLIENT = DATA(CL_CLIENT)
        EXCEPTIONS
          argument_not_found = 1
          plugin_not_active  = 2
          internal_error     = 3
      ).

    CHECK CL_CLIENT IS BOUND.

    DATA(lv_json) = CONV string( p_post_j ).

    " Define a conexão como PUT
    cl_client->request->set_method( 'PUT' ).

    " Define o tipo de Arquivo upado
    cl_client->request->if_http_entity~set_content_type(
      EXPORTING
        CONTENT_TYPE = IF_REST_MEDIA_TYPE=>GC_APPL_JSON
    ).

    " Sobe o Arquivo para Substituição
    cl_client->request->append_cdata( data = lv_json ).

    cl_client->send(
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3
        OTHERS                     = 4 ).

    IF sy-subrc <> 0.
      MESSAGE 'Erro de Coneção' TYPE 'S'.
      EXIT.
    ENDIF.



    cl_client->receive(
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3
        OTHERS                     = 4 ).

    gv_json_get_data = cl_client->response->get_cdata( ).

    cl_client->close( ).

  ENDMETHOD.

  METHOD delet_data_api.

    DATA(lv_url) = get_host_ip( ).

    CL_HTTP_CLIENT=>CREATE_BY_URL(
        EXPORTING
          URL           = lv_url
          ssl_id        = 'ANONYM'
        IMPORTING
          CLIENT = DATA(CL_CLIENT)
        EXCEPTIONS
          argument_not_found = 1
          plugin_not_active  = 2
          internal_error     = 3
      ).

    CHECK CL_CLIENT IS BOUND.

    cl_client->request->set_method( 'DELETE' ).

    cl_client->send(
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3
        OTHERS                     = 4 ).

    CHECK sy-subrc = 0.

    cl_client->receive(
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3
        OTHERS                     = 4 ).

    gv_json_get_data = cl_client->response->get_cdata( ).

    cl_client->close( ).
  ENDMETHOD.

ENDCLASS.
