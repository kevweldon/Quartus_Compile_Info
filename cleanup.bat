@echo off
rmdir qdb tmp-clearbox software DNI /s /q
rmdir .qsys_edit ip sys sandboxes /s /q
del *.rpt *.sof *.summary *.smsg *.pin *~ /s
del *.qsf *.qpf *.qws *.v *.sv *.sdc *.done *.qsys /s
del *.cdf *.sld *.qarlog *.legacy *.xml *.info /s
del *.json *.qdf #*# *.mif *.log *.rec ~* /s


