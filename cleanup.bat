@echo off
rmdir qdb tmp-clearbox software DNI /s /q
rmdir .qsys_edit ip sys /s /q
del *.rpt *.sof *.summary *.smsg *.pin *~ /s
del *.qsf *.qpf *.qws *.v *.sv *.sdc *.done *.qsys /s
del *.cdf *.sld *.qarlog *.legacy *.log *.rec /s
del *.json *.qdf #*# *.mif *.xml ~* /s


