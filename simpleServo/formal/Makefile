SBY=sby
SBT=sbt
SMTBMCIFY=smtbmcify
TOPMODULE=SimpleServo

all: $(TOPMODULE)/PASS

$(TOPMODULE)/PASS: simpleservo.sby ../hdl/simpleservo.v
	-rm -rf $(TOPMODULE)
	$(SBY) simpleservo.sby

mrproper:
	-rm -rf simpleservo
