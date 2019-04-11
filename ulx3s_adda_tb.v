`timescale 1 ns / 100 ps
module ulx3s_adda_tb;

   // initial values
  reg i_clk_tb  = 1'b0;
  wire [6:0] i_btn;
  wire [7:0] o_led_tb;

  reg i_J2_AD_CLK_tb = 1'b0;
  reg  [7:0] i_J2_AD_PORT_tb;

  reg i_J2_DA_CLK_tb = 1'b0;
  wire [7:0] o_J2_DA_PORT_tb;

  wire o_owifi_gpio0_tb;

   initial
     begin
        // vcd dump
        $dumpfile("ulx3s_adda.vcd");
        // the variable 's' is what GTKWave will label the graphs with
        $dumpvars(0, s);
        $monitor("clk_25mhz is %b, o_J2_AD_CLK_tb is %b.", i_clk_tb, o_J2_AD_CLK_tb);

        // setting each elements values at each time interval, must finish with $finish
        #10 i_J2_AD_PORT_tb = 8'b11001100;
        #20 i_J2_AD_PORT_tb = 8'b11001101;
        #30 i_J2_AD_PORT_tb = 8'b11001110;
        #40 i_J2_AD_PORT_tb = 8'b11001111;
        #60 i_J2_AD_PORT_tb = 8'b11010000;
        #110 $finish;
     end

	 always
	   #40 i_clk_tb = ~i_clk_tb;

   // stap of module
   top s(i_clk_tb, 
         i_btn,
         o_led_tb, 
         o_J2_AD_CLK_tb, 
         i_J2_AD_PORT_tb, 
         o_J2_DA_CLK_tb, 
         o_J2_DA_PORT_tb, 
         o_wifi_gpio0_tb);
endmodule
