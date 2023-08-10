CLASS cl_view DEFINITION.
  PUBLIC SECTION.
    METHODS: start_of_selection.
  PRIVATE SECTION.
    METHODS: show_json_get.
ENDCLASS.

CLASS cl_view IMPLEMENTATION.
  METHOD start_of_selection.
    show_json_get( ).
  ENDMETHOD.

  METHOD show_json_get.
    cl_demo_output=>display_json( gv_json_get_data ).
  ENDMETHOD.

ENDCLASS.
