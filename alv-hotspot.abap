REPORT ZSAPeiros.

* DEFINIÇÃO DE TIPOS ---------------------------------------------------
TYPES:
  BEGIN OF ty_relatorio,
    vbeln         TYPE          vbak-vbeln,         "Documento de vendas
    erdat         TYPE          vbak-erdat,         "Data criação
    END OF ty_relatorio.


* TABELAS/ESTRUTURAS INTERNAS ------------------------------------------
DATA:
  t_fieldcat      TYPE          slis_t_fieldcat_alv,"Fieldcat alv grid
  w_fieldcat      TYPE          slis_fieldcat_alv,  "Fieldcat alv grid
  w_layout        TYPE          slis_layout_alv,    "Layout alv grid
  t_relatorio     TYPE TABLE OF ty_relatorio,       "Relatório
  w_relatorio     TYPE          ty_relatorio.       "Relatório


* PARÂMETROS -----------------------------------------------------------
* Parâmetros de Seleção
SELECTION-SCREEN: BEGIN OF BLOCK b01 WITH FRAME TITLE text-t01.
SELECT-OPTIONS:
  s_vbeln         FOR  w_relatorio-vbeln OBLIGATORY.
SELECTION-SCREEN: END OF BLOCK b01.


* INICIAR OBJETOS ------------------------------------------------------
INITIALIZATION.
  sy-title = 'SAPeiros: ALV Hotspot pf-status'.
  %_s_vbeln_%_app_%-text = 'Documento de vendas'.


* SELEÇÃO DOS DADOS ----------------------------------------------------
START-OF-SELECTION.
* Seleção dos Dados
  PERFORM f_seleciona.


* PROCESSAMENTO DOS DADOS ----------------------------------------------
END-OF-SELECTION.
* Monta estrutura e layout do relatório
  CHECK t_relatorio[] IS NOT INITIAL.
  PERFORM zf_estrutura_layout.

* Exibe relatório com dados selecionados
  PERFORM f_relatorio.


* FORMS ----------------------------------------------------------------
* ----------------------------------------------------------------------
* Seleção dos Dados
* ----------------------------------------------------------------------
FORM f_seleciona.
  SELECT vbeln erdat
    FROM vbak
    INTO TABLE t_relatorio
   WHERE vbeln IN s_vbeln.

  IF sy-subrc IS INITIAL.
    SORT t_relatorio BY vbeln.
  ENDIF.
ENDFORM.                    "f_seleciona


*-----------------------------------------------------------------------
* Monta layout e estrutura de campos do relatório
*-----------------------------------------------------------------------
FORM zf_estrutura_layout.
* Layout
  CLEAR w_layout.
  w_layout-zebra             = abap_true.

* Campos do relatório
  CLEAR t_fieldcat[].

  w_fieldcat-tabname        = 'T_RELATORIO'.
  w_fieldcat-fieldname      = 'VBELN'.
  w_fieldcat-ref_tabname    = 'VBAK'.
  w_fieldcat-ref_fieldname  = 'VBELN'.
  w_fieldcat-hotspot        = abap_true.
  w_fieldcat-emphasize      = abap_true.
  w_fieldcat-outputlen      = 14.
  APPEND w_fieldcat TO t_fieldcat.
  CLEAR w_fieldcat.

  w_fieldcat-tabname        = 'T_RELATORIO'.
  w_fieldcat-fieldname      = 'ERDAT'.
  w_fieldcat-ref_tabname    = 'VBAK'.
  w_fieldcat-ref_fieldname  = 'ERDAT'.
  w_fieldcat-outputlen      = 10.
  APPEND w_fieldcat TO t_fieldcat.
  CLEAR w_fieldcat.
ENDFORM.                    "zf_estrutura_layout


*-----------------------------------------------------------------------
* Exibe relatório com dados selecionados
*-----------------------------------------------------------------------
FORM f_relatorio.
  sy-title = 'SAPeiros: ALV Hotspot pf-status'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program      = sy-repid
      is_layout               = w_layout
      it_fieldcat             = t_fieldcat
      i_callback_user_command = 'USER_COMMAND_ALV'
    TABLES
      t_outtab                = t_relatorio
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.

  IF sy-subrc IS NOT INITIAL.

    MESSAGE ID sy-msgid
          TYPE sy-msgty
        NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

  ENDIF.
ENDFORM.                    "f_relatorio


*-----------------------------------------------------------------------
* Ações do ALV
*-----------------------------------------------------------------------
FORM user_command_alv USING u_ucomm       TYPE sy-ucomm
                            us_self_field TYPE slis_selfield.
  IF u_ucomm EQ '&IC1'.

    IF us_self_field-fieldname EQ 'VBELN'.

      READ TABLE t_relatorio
            INTO w_relatorio
           INDEX us_self_field-tabindex.

      IF sy-subrc IS INITIAL.

        SET PARAMETER ID 'AUN' FIELD w_relatorio-vbeln.
        CALL TRANSACTION 'VA02' AND SKIP FIRST SCREEN.

      ENDIF.

    ENDIF.

  ENDIF.
ENDFORM.                    "user_command_alv