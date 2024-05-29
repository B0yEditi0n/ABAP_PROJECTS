

************************************************************************
*                                            DH Consulting             *
************************************************************************
***   Programa : /DHPB/R_INT_EMISS_VPS                                 *
***   Descrição: Automação VPS                                         *
***   Autor    : Caio Abreu de Souza                                   *
***   Data     : 10.01.2023                                            *
***   Documento: Especificação                                         *
************************************************************************

REPORT /DHPB/R_INT_EMISS_VPS.

INCLUDE: /DHPB/I_INT_EMISS_VPS_top,
         /DHPB/I_INT_EMISS_VPS_src,
         /DHPB/I_INT_EMISS_VPS_model,
         /DHPB/I_INT_EMISS_VPS_view,
         /DHPB/I_INT_EMISS_VPS_control,
         /DHPB/I_INT_EMISS_VPS_PBO,
         /DHPB/I_INT_EMISS_VPS_PAI.

INITIALIZATION.
  CREATE OBJECT cl_controller.
  cl_controller->initialization( ).
