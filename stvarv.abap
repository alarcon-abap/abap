*&---------------------------------------------------------------------*
*& Report  ZRDOA_STVARV
*&
*&---------------------------------------------------------------------*
*&
*& Leitura de Range da tabela STVARV
*&---------------------------------------------------------------------*

REPORT  ZRDOA_STVARV.

* Define a range for directory names
DATA: lr_dir_range TYPE range OF char50,
      ls_dir_name LIKE LINE OF lr_dir_range.

* Get the Directory Range from TVARVC
SELECT SIGN opti low high
INTO TABLE lr_dir_range
FROM tvarvc
WHERE name = 'Z_RANGE' "Nome da variável cadastrado no STVARV
AND TYPE = 'S'. "Select Option

IF sy-subrc = 0 AND lr_dir_range IS NOT INITIAL.
  LOOP AT lr_dir_range INTO ls_dir_name.
    WRITE: / ls_dir_name-low.
  ENDLOOP.
ENDIF.