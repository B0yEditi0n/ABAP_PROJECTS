REPORT ZCAS_API_FIREBASE.

INCLUDE: ZCAS_API_FIREBASE_top,
         ZCAS_API_FIREBASE_SCREEN,
         ZCAS_API_FIREBASE_modal,
         ZCAS_API_FIREBASE_view,
         ZCAS_API_FIREBASE_controller.

INITIALIZATION.
  CREATE OBJECT cl_controller.

AT SELECTION-SCREEN.
  cl_controller->at_seletion_screen( ).
START-OF-SELECTION.
  cl_controller->start_of_selection( ).
