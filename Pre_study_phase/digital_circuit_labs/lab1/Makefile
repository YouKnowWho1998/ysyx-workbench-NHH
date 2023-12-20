Module = top

.PHONY:sim verilate build waves lint clean

sim: waveform.vcd

waves: waveform.vcd
	gtkwave waveform.vcd

waveform.vcd: ./obj_dir/V$(Module)
	./obj_dir/V$(Module) +verilator+rand+reset+2

./obj_dir/V$(Module): stamp.verilate
	make -C obj_dir -f V$(Module).mk V$(Module)

stamp.verilate: $(Module).v tb.cpp
	verilator -Wall --trace --x-assign unique --x-initial unique -cc $(Module).v --exe tb.cpp

lint: $(Module).V
	verilator --lint-only $(Module).V

clean:
	rm -rf ./obj_dir
	rm -rf ./waveform.vcd
