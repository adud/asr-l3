


##########################################
# Analyse (ghdl -a)

fulladder.o: fulladder.vhdl
	ghdl -a fulladder.vhdl

testbench_fulladder.o: testbench_fulladder.vhdl
	ghdl -a fulladder.vhdl

# TODO:  ajoutez des  règles similaires  pour "analyser"  vos fichiers
# VHDL à vous. Chaque "truc.o" a comme dépendance "truc.vhdl"

##########################################
# Elaboration (ghdl -e)

testbench_fulladder: testbench_fulladder.o fulladder.o
	ghdl -e $@

# TODO:  ajoutez  des  règles  similaires  pour  "élaborer"  tous  vos
# exécutables. Chaque exécutable  "testbench_bidule" a des dépendances
# sur tous les "machins.o" impliqués dans le circuit

##########################################
# Execution


# Astuce: vous pouvez lancer gtkwave une  seule fois, en tâche de fond
# (c'est à dire avec un "&" en fin de ligne). Ensuite, chaque fois que
# vous simulez votre circuit  vous pouvez _rafraîchir_ le chronogramme
# pour qu'il  reflète le  nouveau contenu du  fichier VCD.  Pour cela,
# cliquez dans le menu File -> Reload Waveform.

run_testbench_fulladder: testbench_fulladder
	./testbench_fulladder --stop-time=20ns --vcd=testbench_fulladder.vcd

gtkwave:
	gtkwave *.vcd &


##########################################
# Nettoyage

clean:
	-rm -f *.o work-obj93.cf *.vcd testbench_fulladder

