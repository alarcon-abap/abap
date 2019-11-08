REPORT ZSAPeiros.

TYPE-POOLS: slis.

TYPES:
* Estrutura de campos do ALV1
  BEGIN OF ty_alv1,
    carrid TYPE sflight-carrid,                   "Campo 1
    connid TYPE sflight-connid,                   "Campo 2
    END OF ty_alv1,

* Estrutura de campos do ALV2
  BEGIN OF ty_alv2,
    carrid TYPE sflight-carrid,                   "Campo 1
    END OF ty_alv2.

* Tabelas e estruturas globais
DATA:
  gt_fieldcat1 TYPE          slis_t_fieldcat_alv WITH HEADER LINE, "Alv campos
  gt_fieldcat2 TYPE          slis_t_fieldcat_alv WITH HEADER LINE, "Alv campos
  gt_events    TYPE          slis_alv_event OCCURS 0, "Alv eventos
  gt_alv1      TYPE TABLE OF ty_alv1 INITIAL SIZE 0,  "Alv 1
  gt_alv2      TYPE TABLE OF ty_alv2 INITIAL SIZE 0,  "Alv 2
  wa_layout    TYPE          slis_layout_alv.         "Alv layout

* Variáveis globais
DATA:
  gv_repid   TYPE sy-repid,                       "Programa
  gv_alv(30) TYPE c.                              "Alv


* Seleciona dados
PERFORM p_seleciona_dados.

* Define layout de tela
PERFORM p_layout.

* Monta campos do Alv 1
PERFORM p_fieldcat1.

* Monta campos do Alv 2
PERFORM p_fieldcat2.

* Mescla e visualiza relatório
PERFORM p_ver_relatorio.


*---------------------------------------------------------------------*
* Seleciona dados
*---------------------------------------------------------------------*
FORM p_seleciona_dados.
  SELECT carrid connid FROM sflight
    INTO TABLE gt_alv1
   UP TO 10 ROWS.

  IF sy-subrc IS NOT INITIAL.
    CLEAR gt_alv1[].
  ENDIF.

  SELECT carrid FROM sflight
    INTO TABLE gt_alv2
   UP TO 10 ROWS.

  IF sy-subrc IS NOT INITIAL.
    CLEAR gt_alv2[].
  ENDIF.
ENDFORM.                    "p_seleciona_dados


*---------------------------------------------------------------------*
* Define layout de tela
*---------------------------------------------------------------------*
FORM p_layout.
  wa_layout-colwidth_optimize = 'X'.
ENDFORM.                    "p_layout


*---------------------------------------------------------------------*
* Monta campos do Alv 1
*---------------------------------------------------------------------*
FORM p_fieldcat1.
  CLEAR gt_fieldcat1.
  gt_fieldcat1-seltext_l = 'CARRID'.
  gt_fieldcat1-row_pos = 0.
  gt_fieldcat1-col_pos = 1.
  gt_fieldcat1-fieldname = 'CARRID'.
  APPEND gt_fieldcat1.

  CLEAR gt_fieldcat1.
  gt_fieldcat1-seltext_l = 'CONNID'.
  gt_fieldcat1-row_pos = 0.
  gt_fieldcat1-col_pos = 1.
  gt_fieldcat1-fieldname = 'CONNID'.
  APPEND gt_fieldcat1.
ENDFORM.                    "p_fieldcat1


*---------------------------------------------------------------------*
* Monta campos do Alv 2
*---------------------------------------------------------------------*
FORM p_fieldcat2.
  CLEAR gt_fieldcat2.
  gt_fieldcat2-seltext_l = 'CARRID'.
  gt_fieldcat2-row_pos = 0.
  gt_fieldcat2-col_pos = 1.
  gt_fieldcat2-fieldname = 'CARRID'.
  APPEND gt_fieldcat2.
ENDFORM.                    "p_fieldcat2


*---------------------------------------------------------------------*
* Mescla e visualiza relatório
*---------------------------------------------------------------------*
FORM p_ver_relatorio.

  gv_repid = sy-repid.

  CALL FUNCTION 'REUSE_ALV_BLOCK_LIST_INIT'
    EXPORTING
      i_callback_program = gv_repid.

  gv_alv = 'GT_ALV1'.
  CALL FUNCTION 'REUSE_ALV_BLOCK_LIST_APPEND'
    EXPORTING
      is_layout                  = wa_layout
      it_fieldcat                = gt_fieldcat1[]
      i_tabname                  = gv_alv
      it_events                  = gt_events
    TABLES
      t_outtab                   = gt_alv1
    EXCEPTIONS
      program_error              = 1
      maximum_of_appends_reached = 2.

  gv_alv = 'GT_ALV2'.
  CALL FUNCTION 'REUSE_ALV_BLOCK_LIST_APPEND'
    EXPORTING
      is_layout                  = wa_layout
      it_fieldcat                = gt_fieldcat2[]
      i_tabname                  = gv_alv
      it_events                  = gt_events
    TABLES
      t_outtab                   = gt_alv2
    EXCEPTIONS
      program_error              = 1
      maximum_of_appends_reached = 2.

  CALL FUNCTION 'REUSE_ALV_BLOCK_LIST_DISPLAY'.
ENDFORM.                    "p_ver_relatorio