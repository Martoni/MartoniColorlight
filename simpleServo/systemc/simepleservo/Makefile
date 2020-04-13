VERILATOR=verilator
VERILATOR_FLAGS=--trace -O3 -noassert
VERILATOR_DIR=obj_dir
HDLSRC=../../hdl

$(VERILATOR_DIR)/VsimpleServo.h: $(HDLSRC)/simpleservo.v test_simpleservo.cpp
	echo "convert verilog model in C++ model" >> time.txt
	date >> time.txt
	$(VERILATOR) -Wall -cc $< $(VERILATOR_FLAGS)\
		--exe test/test_button_deb.cpp
	echo "end of conversion" >> time.txt
	date >> time.txt

verilator_button: $(VERILATOR_DIR)/Vbutton_deb.h
	echo "simulate verilator model" >> time.txt
	date >> time.txt
	$(MAKE) -C $(VERILATOR_DIR)/ -j -f Vbutton_deb.mk Vbutton_deb
	./$(VERILATOR_DIR)/Vbutton_deb
	echo "end of simulation" >> time.txt
	date >> time.txt

clean:
	-rm -rf $(SIMU_DIR)
	-rm -rf $(VERILATOR_DIR)
	-rm time.txt
