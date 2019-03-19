#include <verilatedos.h>
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <time.h>
#include <sys/types.h>
#include <signal.h>
#include "verilated.h"
#include "Vulx3s_adda.h"
#include "testb.h"


template<class Vulx3s_adda>	class TESTBENCH {
	unsigned long	m_tickcount;
	Vulx3s_adda	*m_core;

	TESTBENCH(void) {
		m_core = new Vulx3s_adda;
		m_tickcount = 0l;
	}

	virtual ~TESTBENCH(void) {
		delete m_core;
		m_core = NULL;
	}

	virtual void	reset(void) {
		m_core->i_reset = 1;
		// Make sure any inheritance gets applied
		this->tick();
		m_core->i_reset = 0;
	}

	virtual void	tick(void) {
		// Increment our own internal time reference
		m_tickcount++;

		// Make sure any combinatorial logic depending upon
		// inputs that may have changed before we called tick()
		// has settled before the rising edge of the clock.
		m_core->i_clk = 0;
		m_core->eval();

		// Toggle the clock

		// Rising edge
		m_core->i_clk = 1;
		m_core->eval();

		// Falling edge
		m_core->i_clk = 0;
		m_core->eval();
	}

	virtual bool	done(void) { return (Verilated::gotFinish()); }
};

class	ulx3s_adda_TB : public TESTB<Vulx3s_adda> {

	virtual void	tick(void) {
		// Request that the testbench toggle the clock within
		// Verilator
		TESTB<Vulx3s_adda>::tick();

		 //Now we'll debug by printf's and examine the
		 //internals of m_core
		// printf((m_core->VL_IN8) ? "ctr" : "   ");
	}
};

int	main(int argc, char **argv) {
	Verilated::commandArgs(argc, argv);

	TESTBENCH<Vulx3s_adda> *tb = new TESTBENCH<Vulx3s_adda>();

	while (!tb->done()) {
		tb->tick();
	}

	TESTB<Vulx3s_adda>	*tb
		= new TESTB<Vulx3s_adda>;
	tb->opentrace("ulx3s_adda.vcd");
	tb->m_core->btn= 0;

	for (int i=0; i < 1000000; i++) {
	  tb->tick();
	}

	printf("\n\nSimulation complete\n");
	exit(EXIT_SUCCESS);
}