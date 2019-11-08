*&---------------------------------------------------------------------*
*& Report  ZRDO_POP
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZRDO_POP.

DATA:
      t_fields TYPE TABLE OF sval, "Atributos tabela
      w_fields TYPE          sval. "Atributos tabela

w_fields-tabname   = 'KNA1'.
w_fields-fieldname = 'KUNNR'.
w_fields-field_obl = abap_true.
APPEND w_fields TO t_fields.
CLEAR w_fields.

*w_fields-tabname   = 'MARA'.
*w_fields-fieldname = 'MEINS'.
*APPEND w_fields TO t_fields.
*CLEAR w_fields.

CALL FUNCTION 'POPUP_GET_VALUES'
EXPORTING
  popup_title = 'Informe os dados corretamente'
TABLES
  FIELDS      = t_fields.

LOOP AT t_fields INTO w_fields.
  WRITE:/ w_fields-VALUE.
ENDLOOP.