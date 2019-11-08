REPORT ZSAPeiros.

TYPES:
   BEGIN OF ty_saida,
     campo1(4)  TYPE c,
     campo2(6)  TYPE p DECIMALS 3,
     color(4)   TYPE c,
   END OF ty_saida.

TYPE-POOLS:
   slis.

DATA:
  gt_saida      TYPE TABLE OF ty_saida,
  wa_saida      TYPE          ty_saida,
  gt_fieldcat   TYPE TABLE OF slis_fieldcat_alv,
  wa_fieldcat   TYPE          slis_fieldcat_alv,
  wa_layout     TYPE          slis_layout_alv.


PARAMETERS:
  p_top_1       RADIOBUTTON GROUP r1,
  p_top_2       RADIOBUTTON GROUP r1.


INITIALIZATION.
  sy-title = 'SAPeiros: ALV TOP-OF-PAGE'.
  %_p_top_1_%_app_%-text = 'TOP-OF-PAGE'.
  %_p_top_2_%_app_%-text = 'HTML-TOP-OF-PAGE'.


START-OF-SELECTION.
* Seleção dos dados
  PERFORM frm_select_data.


END-OF-SELECTION.
  sy-title = 'SAPeiros: ALV TOP-OF-PAGE'.

* Monta estrutura do relatório
  PERFORM frm_alv_fieldcat.

* Define detalhes no layout do relatório
  PERFORM frm_alv_layout.

* Exibe o relatório
  PERFORM frm_alv_show.


*---------------------------------------------------------------------*
* Seleção dos dados
*---------------------------------------------------------------------*
FORM frm_select_data.
  wa_saida-campo1 = '1'.
  wa_saida-campo2 = '8'.
  APPEND wa_saida TO gt_saida.

  wa_saida-campo1 = '2'.
  wa_saida-campo2 = '-73'.
  APPEND wa_saida TO gt_saida.

  wa_saida-campo1 = '3'.
  wa_saida-campo2 = '20'.
  APPEND wa_saida TO gt_saida.

  wa_saida-campo1 = '4'.
  wa_saida-campo2 = '50'.
  APPEND wa_saida TO gt_saida.

  wa_saida-campo1 = '5'.
  wa_saida-campo2 = '-55'.
  APPEND wa_saida TO gt_saida.

  wa_saida-campo1 = '6'.
  wa_saida-campo2 = '90'.
  APPEND wa_saida TO gt_saida.

  wa_saida-campo1 = '7'.
  wa_saida-campo2 = '100'.
  APPEND wa_saida TO gt_saida.

* Atualiza cores das linhas
  LOOP AT gt_saida INTO wa_saida.

    IF wa_saida-campo2 < 0.
      wa_saida-color = 'C610'. "Vermelho
    ELSEIF wa_saida-campo2 > 0 AND wa_saida-campo2 < 50.
      wa_saida-color = 'C310'. "Amarelo
    ELSEIF wa_saida-campo2 >= 50.
      wa_saida-color = 'C510'. "Azul
    ENDIF.

    MODIFY gt_saida FROM wa_saida INDEX sy-tabix.

  ENDLOOP.
ENDFORM.                    "frm_select_data


*---------------------------------------------------------------------*
* Monta estrutura do relatório
*---------------------------------------------------------------------*
FORM frm_alv_fieldcat.
  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'CAMPO1'.
  wa_fieldcat-seltext_m = 'Campo 1'.
  wa_fieldcat-tabname   = 'GT_SAIDA'.
  APPEND wa_fieldcat TO gt_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'CAMPO2'.
  wa_fieldcat-seltext_m = 'Campo 2'.
  wa_fieldcat-tabname   = 'GT_SAIDA'.
  APPEND wa_fieldcat TO gt_fieldcat.
ENDFORM.                    "frm_alv_fieldcat


*---------------------------------------------------------------------*
* Define detalhes no layout do relatório
*---------------------------------------------------------------------*
FORM frm_alv_layout.
  wa_layout-expand_all        = 'X'.
  wa_layout-colwidth_optimize = 'X'.
  wa_layout-zebra             = 'X'.
  wa_layout-info_fieldname    = 'COLOR'.
ENDFORM.                    "frm_alv_layout


*---------------------------------------------------------------------*
* Exibe o relatório
*---------------------------------------------------------------------*
FORM frm_alv_show.
  DATA:
    lv_repid      TYPE sy-repid.              "Nome do Programa

  lv_repid = sy-repid.

  IF p_top_1 = abap_true.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_callback_program     = lv_repid
        i_callback_top_of_page = 'TOP_OF_PAGE'
        is_layout              = wa_layout
        it_fieldcat            = gt_fieldcat[]
      TABLES
        t_outtab               = gt_saida
      EXCEPTIONS
        program_error          = 1
        OTHERS                 = 2.

  ELSE.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_callback_program          = lv_repid
        i_callback_html_top_of_page = 'HTML_TOP_OF_PAGE'
        is_layout                   = wa_layout
        it_fieldcat                 = gt_fieldcat[]
      TABLES
        t_outtab                    = gt_saida
      EXCEPTIONS
        program_error               = 1
        OTHERS                      = 2.

  ENDIF.

  IF sy-subrc <> 0.
    LEAVE LIST-PROCESSING.
  ENDIF.
ENDFORM.                    "frm_alv_show


* TOPO standard
FORM top_of_page.
* Declarações locais
  DATA:
    gt_header     TYPE slis_t_listheader,     "H = Header, S = Selection, A = Action
    wa_header     TYPE slis_listheader,       "H = Header, S = Selection, A = Action
    lv_texto      TYPE slis_listheader-info,  "Texto
    lv_linesc(10) TYPE c.                     "Qtd registros

* Título
  wa_header-typ  = 'H'.
  wa_header-info = 'Relatório de linhas coloridas'.
  APPEND wa_header TO gt_header.
  CLEAR wa_header.

* Usuário
  wa_header-typ  = 'S'.
  wa_header-key  = 'Usuário:'.
  wa_header-info = sy-uname.
  APPEND wa_header TO gt_header.
  CLEAR wa_header.

* Data
  wa_header-typ  = 'S'.
  wa_header-key  = 'Data:'.
  WRITE sy-datum TO wa_header-info DD/MM/YYYY.
  APPEND wa_header TO gt_header.
  CLEAR wa_header.

* Hora
  wa_header-typ  = 'S'.
  wa_header-key  = 'Hora:'.
  wa_header-info = sy-uzeit.
  APPEND wa_header TO gt_header.
  CLEAR wa_header.

* Número de registros
  DESCRIBE TABLE gt_saida LINES lv_linesc.
  CONCATENATE 'Registros:'
              lv_linesc
         INTO lv_texto
              SEPARATED BY space.
  wa_header-typ  = 'A'.
  wa_header-info = lv_texto.
  APPEND wa_header TO gt_header.
  CLEAR wa_header.

* Imprime o cabeçalho
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = gt_header
      i_logo             = 'ENJOYSAP_LOGO'.
ENDFORM.                    "top_of_page


* TOPO formato HTML
FORM html_top_of_page USING document TYPE REF TO cl_dd_document.
* Declarações locais
  DATA:
    lv_text(255)  TYPE c,                     "Texto
    lv_linesc(10) TYPE c.                     "Qtd registros

* Título
  CALL METHOD document->add_text
    EXPORTING
      text      = 'Relatório de linhas coloridas'
      sap_style = 'heading'.

* Distância da imagem
  CALL METHOD document->add_gap
    EXPORTING
      width = 150.

* Imagem
  CALL METHOD document->add_picture
    EXPORTING
      picture_id = 'ENJOYSAP_LOGO'.

* Linha horizontal
  CALL METHOD document->new_line( ).

  lv_text(185) = sy-uline.

  CALL METHOD document->add_text
    EXPORTING
      text = lv_text.

* Usuário
  CALL METHOD document->new_line( ).

  CALL METHOD document->add_text
    EXPORTING
      text         = 'Usuário:'
      sap_color    = cl_dd_area=>list_heading_inv
      sap_emphasis = cl_dd_area=>strong.

  CALL METHOD document->add_gap
    EXPORTING
      width = 2.

  WRITE sy-uname TO lv_text.

  CALL METHOD document->add_text
    EXPORTING
      text = lv_text.

* Data
  CALL METHOD document->new_line( ).

  CALL METHOD document->add_text
    EXPORTING
      text         = 'Data:'
      sap_color    = cl_dd_area=>list_heading_inv
      sap_emphasis = cl_dd_area=>strong.

  CALL METHOD document->add_gap
    EXPORTING
      width = 6.

  WRITE sy-datum TO lv_text DD/MM/YYYY.

  CALL METHOD document->add_text
    EXPORTING
      text = lv_text.

* Hora
  CALL METHOD document->new_line( ).

  CALL METHOD document->add_text
    EXPORTING
      text         = 'Hora:'
      sap_color    = cl_dd_area=>list_heading_inv
      sap_emphasis = cl_dd_area=>strong.

  CALL METHOD document->add_gap
    EXPORTING
      width = 6.

  WRITE sy-uzeit TO lv_text.

  CALL METHOD document->add_text
    EXPORTING
      text = lv_text.

* Número de registros
  CALL METHOD document->new_line( ).

  DESCRIBE TABLE gt_saida LINES lv_linesc.

  CALL METHOD document->add_text
    EXPORTING
      text         = 'Registros:'
      sap_color    = cl_dd_area=>list_heading_inv
      sap_emphasis = cl_dd_area=>strong.

  CALL METHOD document->add_gap
    EXPORTING
      width = 0.

  lv_text = lv_linesc.

  CALL METHOD document->add_text
    EXPORTING
      text = lv_text.
ENDFORM.                    "html_top_of_page