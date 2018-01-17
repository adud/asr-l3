CFLAGS = -Wall -Wextra -O2 -std=c++11
LDFLAGS = -lSDL2 -lpthread 
EXEC = simu
# The directory containing the different files :
SIMUSRC = simu.src
SIMUOBJ = simu.obj
ASMSRC = asm.src
ASMOBJ = asm.exec
# The different lists of files
CPPFILES = $(wildcard $(SIMUSRC)/*.cpp)
OFILES = $(CPPFILES:$(SIMUSRC)/%.cpp=$(SIMUOBJ)/%.o)
DFILES = $(OFILES:%.o=%.d) # the .d files are stored in simu.obj
SFILES = $(wildcard $(ASMSRC)/*.s)
OBJFILES = $(SFILES:$(ASMSRC)/%.s=$(ASMOBJ)/%.obj)
ASMDFILES = $(OBJFILES:%.obj=%.d)
# the configuration file, defining the WORDSIZE variable
CONFIG = .config

GRAPH = $(ASMSRC)/pictr2.s

include $(CONFIG)

all : $(EXEC) $(OBJFILES) $(GRAPH)

$(EXEC) : $(OFILES)
	$(CXX) -o $@ $^ $(LDFLAGS)

-include $(DFILES)
-include $(ASMDFILES)

$(SIMUOBJ)/%.o: $(SIMUSRC)/%.cpp $(CONFIG)
	mkdir -p $(SIMUOBJ)
	$(CXX) $(CFLAGS) -DWORDSIZE=$(WORDSIZE) -DINOUT=$(INOUT) -MMD -MP -o $@ -c $<

$(ASMOBJ)/%.obj: $(ASMSRC)/%.s $(CONFIG)
	mkdir -p $(ASMOBJ)
	python2 asm.py -a $(WORDSIZE) -MD -v 1 $< -o $@

$(GRAPH): bitmap/r2.jpg
	cd bitmap && ./genr2.sh
r2: all
	./simu -g -m bitmap/grlib.mem asm.exec/demo.obj

rf: all # exécute le rendu final
	./simu -g asm.exec/pluie.obj

clean :
	$(RM) $(OFILES) $(DFILES) $(OBJFILES) $(ASMDFILES) $(GRAPH) 
cleaner : clean
	$(RM) $(EXEC)

