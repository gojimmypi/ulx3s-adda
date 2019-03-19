module top(
  input  clk_25mhz,
  input [6:0] btn,
  output [7:0] led,

  output J2_AD_CLK,
  input  [7:0] J2_AD_PORT,

  output J2_DA_CLK,
  output [7:0] J2_DA_PORT,

  output wifi_gpio0
);


error we are not using this file!
 

	wire i_clk;
	assign i_clk= clk_25mhz;

	// Tie GPIO0, keep board from rebooting
    assign wifi_gpio0 = 1'b1;
	
	reg[7:0] o_value;
	assign J2_DA_PORT = o_value;

	reg [7:0] o_led;
	assign led= o_led;

	localparam ctr_width = 32;
    reg [ctr_width-1:0] ctr = 8'b1111_1111;

	reg [7:0] i_ad_port_value;
	// assign i_ad_port_value[7:0] = J2_AD_PORT[7:0];

	// A/D Input Clock
	// "The pipelined architecture of the AD9280 operates on both rising and falling edges of the input clock.
	// The AD9280 is designed to support a conversion rate of 32 MSPS; running the part at slightly faster clock rates may
    // be possible, although at reduced performance levels." (see AD9280 datasheet, page 15)
	assign J2_AD_CLK = i_clk;

	// D/A Outout Clock
	// AD9708 TxDAC: 125 MSPS Update Rate
	// "The DAC output is updated following the rising edge of the clock as shown in Figure 1 and is designed to support a
	// clock rate as high as 125 MSPS."
	// output propagation delay tPD is typically 1ns (see AD9708 datasheet page 3)
	assign J2_DA_CLK = ~i_clk;

	// on the falling edge of the i_clk we update the D/A output
	// TODO - does this introduce phase shift? (yes, probably)
	//always @(negedge i_clk) begin
	//	 J2_DA_PORT[7:0] <= i_ad_port_value[7:0];
	//end

	always @(posedge i_clk) begin
		// 14ns after edge, data is stable
		ctr <= ctr + 1;
		 i_ad_port_value[7:0] = J2_AD_PORT[7:0];
		// o_value[7:0] <= i_ad_port_value; // J2_AD_PORT[7:0] && ctr[7:0];
		// o_led[5:0] <= o_value[7:0]; // ctr[23:18];
		// works: o_led[6:6] <= ctr[23:23];
		// works: o_led[7:0] <= i_ad_port_value[7:0];
		o_led[7:0] <= i_ad_port_value[7:0];
		// J2_DA_PORT[7:0] <= i_ad_port_value[7:0];
		// o_led[0:0] <=  ctr[23:23];
		// J2_AD_CLK <= ctr[0:0];
		// J2_DA_CLK <=   ctr[0:0];
		o_value[7:0] <= i_ad_port_value[7:0];
	end

endmodule

