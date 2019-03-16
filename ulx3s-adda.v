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

	reg [0:0] o_AD_TRIG;

	reg [7:0] i_ad_port_value;
	assign i_ad_port_value = J2_AD_PORT[7:0];

	assign J2_AD_CLK = o_AD_TRIG;
	assign J2_DA_CLK = ~o_AD_TRIG;

	//always begin
	//	J2_AD_CLK <= i_clk;
	//	J2_DA_CLK <= ~i_clk;
	//end

	always @(posedge i_clk) begin
		ctr <= ctr + 1;
		o_value[7:0] <= i_ad_port_value; // J2_AD_PORT[7:0] && ctr[7:0];
		// o_led[5:0] <= o_value[7:0]; // ctr[23:18];
		// works: o_led[6:6] <= ctr[23:23];
		o_led[7:0] <= i_ad_port_value[7:0];
		// o_led[0:0] <=  ctr[23:23];
		o_AD_TRIG <= ctr[0:0];

	end

endmodule

