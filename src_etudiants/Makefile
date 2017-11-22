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
# the configuration file, defining the WORDSIZE variable
CONFIG = .config

include $(CONFIG)
 
all : $(EXEC) $(OBJFILES)
	
$(EXEC) : $(OFILES)
	$(CXX) -o $@ $^ $(LDFLAGS)

-include $(DFILES)

$(SIMUOBJ)/%.o: $(SIMUSRC)/%.cpp $(CONFIG)
	mkdir -p $(SIMUOBJ)
	$(CXX) $(CFLAGS) -DWORDSIZE=$(WORDSIZE) -MMD -MP -o $@ -c $<

$(ASMOBJ)/%.obj: $(ASMSRC)/%.s
	python asm.py -a $(WORDSIZE) $<
	mkdir -p $(ASMOBJ)
	mv $(ASMSRC)/$*.obj $@

clean :
	$(RM) $(OFILES) $(DFILES)
cleaner : clean
	$(RM) $(EXEC)

