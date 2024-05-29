REPORT ycas_teste.

SELECTION-SCREEN: BEGIN OF SCREEN 9000,
                  END OF SCREEN 9000.


INITIALIZATION.

DATA o_chart TYPE REF TO cl_gui_chart_engine.
CONCATENATE '<ChartData>'
    '<Categories>'
      '<Category>Cat 1</Category>'
      '<Category>Cat 2</Category>'
      '<Category>Cat 3</Category>'
    '</Categories>'
    '<Series Customizing="Series1" label="Series 1"  >'
      '<Point>'
        '<Value type="y">10</Value>'
      '</Point>'
      '<Point>'
        '<Value type="y">10</Value>'
      '</Point>'
      '<Point>'
        '<Value type="y">7</Value>'
      '</Point>'
    '</Series>'
    '<Series Customizing="Series2" label="Series 2"  >'
      '<Point>'
        '<Value type="y">7</Value>'
      '</Point>'
      '<Point>'
        '<Value type="y">9</Value>'
      '</Point>'
      '<Point>'
        '<Value type="y">23</Value>'
      '</Point>'
    '</Series>'
'</ChartData>' INTO DATA(lv_xml).

CREATE OBJECT o_chart
  EXPORTING
    parent     = cl_gui_container=>screen0.

  o_chart->SET_DATA(
    DATA = lv_xml
  ).

  o_chart->render( ).
  call SCREEN 9000.
