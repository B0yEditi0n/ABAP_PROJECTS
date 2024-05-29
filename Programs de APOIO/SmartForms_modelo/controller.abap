CLASS cl_controller DEFINITION.
  PUBLIC SECTION.
    METHODS: constructor,
             initialization,
             m_input_user IMPORTING u_command TYPE char70.

  PRIVATE SECTION.
    DATA: cl_model TYPE REF TO cl_model,
          cl_view  TYPE REF TO cl_view.

ENDCLASS.

CLASS cl_controller IMPLEMENTATION.

  METHOD: constructor.
    CREATE OBJECT: cl_model,
                   cl_view.

    me->cl_view->cl_model = cl_model.
  ENDMETHOD. " constructor

  METHOD initialization.
    me->cl_view->initialization( ).
  ENDMETHOD. " initialization

  METHOD m_input_user.
    me->cl_view->inputuser( u_command ).

  ENDMETHOD. " m_input_user

ENDCLASS.

DATA: cl_controller TYPE REF TO cl_controller.
