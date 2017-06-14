@echo "Running Mico8 XO2 Simulation"
asim +access +r -lib work -L ovi_machxo2  -L pmi_work -advdataflow tb 
# add a wave file (i2c_waves.do or spi_waves.do)
# then: run 200 us

