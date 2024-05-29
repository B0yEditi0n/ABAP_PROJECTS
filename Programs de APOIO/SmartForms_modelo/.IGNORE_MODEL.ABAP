REPORT ZDOWNLOADSM .

DATA : gt_vbak TYPE TABLE OF vbak.

DATA :
  form_name TYPE rs38l_fnam,
  gs_control_params TYPE ssfctrlop,
  gs_output_options TYPE ssfcompop.

DATA :
  t_otfdata TYPE ssfcrescl,
  t_pdf_tab LIKE tline OCCURS 0 WITH HEADER LINE, " SAPscript: Text Lines
  t_otf TYPE itcoo OCCURS 0 WITH HEADER LINE, " OTF Structure
  w_bin_filesize(10) TYPE c.

DATA :
  gv_initialDirectory TYPE STRING,
  gv_filename TYPE STRING,
  gv_path TYPE STRING,
  gv_fullpath TYPE STRING.

CONSTANTS : c_defaultpath(100) TYPE C VALUE 'C:\'.

SELECTION-SCREEN BEGIN OF BLOCK BLOCK-1 WITH FRAME TITLE TEXT-001.
  PARAMETERS : pa_file LIKE RLGRAP-FileName DEFAULT c_defaultpath.
SELECTION-SCREEN END OF BLOCK BLOCK-1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_file.
  PERFORM u_SelectFolder USING pa_file.


START-OF-SELECTION.
  PERFORM uf_GetReportData.
  PERFORM uf_GetSmartFormModuleName.
  PERFORM uf_RunSmartForm.
  PERFORM uf_ConvertToOTF.
  PERFORM uf_DownloadToClient.
END-OF-SELECTION.

form U_SELECTFOLDER using p_pa_file.

  DATA :
    lv_subrc LIKE sy-subrc,
    lt_it_tab TYPE filetable.

  IF pa_file IS INITIAL.
    gv_initialDirectory = 'C:\'.
  ELSE.
    gv_initialDirectory = pa_file.
  ENDIF.

  " Display File Open Dialog control/screen
  CALL METHOD cl_gui_frontend_services=>FILE_SAVE_DIALOG
  EXPORTING
    WINDOW_TITLE = 'Save SmartForm as ...'
    DEFAULT_EXTENSION = '.pdf'
    DEFAULT_FILE_NAME = 'smartform.pdf'
    FILE_FILTER = '.pdf'
    INITIAL_DIRECTORY = gv_initialDirectory
  CHANGING
    FILENAME = gv_filename
    PATH = gv_path
    FULLPATH = gv_fullpath.

  IF sy-subrc = 0.
    " Write path on input area
    p_pa_file = gv_fullpath.
  ENDIF.

endform. " U_SELECTFOLDER

form UF_DOWNLOADTOCLIENT .

  DATA : lv_filename(128) TYPE C.

  lv_filename = gv_fullpath.

  CALL FUNCTION 'WS_DOWNLOAD'
  EXPORTING
    BIN_FILESIZE = w_bin_filesize
    FILENAME = lv_filename
    FILETYPE = 'BIN'
  TABLES
    data_tab = t_pdf_tab
  EXCEPTIONS
    FILE_OPEN_ERROR = 1
    FILE_WRITE_ERROR = 2
    INVALID_FILESIZE = 3
    INVALID_TYPE = 4
    NO_BATCH = 5
    UNKNOWN_ERROR = 6
    INVALID_TABLE_WIDTH = 7
    GUI_REFUSE_FILETRANSFER = 8
    CUSTOMER_ERROR = 9
    NO_AUTHORITY = 10
    OTHERS = 11.

endform. " UF_DOWNLOADTOCLIENT

form UF_GETREPORTDATA .

  SELECT * FROM vbak INTO TABLE gt_vbak
    WHERE vbeln EQ '0100000004'.

endform. " UF_GETREPORTDATA

form UF_GETSMARTFORMMODULENAME .

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
  EXPORTING
    formname = 'ZSMARTFORMS_SALES_DOCUMENTS'
  IMPORTING
    fm_name = form_name
  EXCEPTIONS
    no_form = 1
    no_function_module = 2
    OTHERS = 3.

endform. " UF_GETSMARTFORMMODULENAME

form UF_RUNSMARTFORM .

  gs_output_options-tdnoprev = 'X'.
  gs_control_params-no_dialog = 'X'.
  gs_control_params-getotf = 'X'.

  CALL FUNCTION form_name
  EXPORTING
    control_parameters = gs_control_params
    output_options = gs_output_options
    user_settings = 'X'
  IMPORTING
    job_output_info = t_otfdata
  TABLES
    it_vbak = gt_vbak
  EXCEPTIONS
    formatting_error = 1
    internal_error = 2
    send_error = 3
    user_canceled = 4
    OTHERS = 5.

endform. " UF_RUNSMARTFORM

form UF_CONVERTTOOTF .

  t_otf[] = t_otfdata-otfdata[].

  CALL FUNCTION 'CONVERT_OTF'
  EXPORTING
    FORMAT = 'PDF'
    MAX_LINEWIDTH = 132
  IMPORTING
    BIN_FILESIZE = w_bin_filesize
  TABLES
    otf = t_otf
    lines = t_pdf_tab
  EXCEPTIONS
    ERR_MAX_LINEWIDTH = 1
    ERR_FORMAT = 2
    ERR_CONV_NOT_POSSIBLE = 3
    ERR_BAD_OTF = 4.

endform. " UF_CONVERTTOOTF