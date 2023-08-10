CLASS cl_controller DEFINITION.
  PUBLIC SECTION.

    DATA: cl_model TYPE REF TO cl_model,
          cl_view  TYPE REF TO cl_view.

    METHODS: constructor,
             at_seletion_screen,
             start_of_selection.

ENDCLASS.

CLASS cl_controller IMPLEMENTATION.
  METHOD constructor.
    CREATE OBJECT: cl_model,
                   cl_view.
  ENDMETHOD.

  METHOD at_seletion_screen.
    cl_model->at_seletion_screen( ).
  ENDMETHOD.

  METHOD start_of_selection.
    cl_view->start_of_selection( ).
  ENDMETHOD.

ENDCLASS.

DATA: cl_controller TYPE REF TO cl_controller.
