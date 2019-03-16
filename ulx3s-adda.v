module top(
  input  clk_25mhz,
  input [7:0] AD_PORT,
  output [7:0] DA_PORT,
  output wifi_gpio0
);

	wire i_clk;
	assign i_clk= clk_25mhz;

	// Tie GPIO0, keep board from rebooting
    assign wifi_gpio0 = 1'b1;
	
	reg[7:0] o_value;
	assign DA_PORT = o_value;

	//wire [7:0] AD_PORT;
	//wire [7:0] DA_PORT;

//	assign DA_PORT[7] = gp[14]; // U18; // DAD87 pin 6
//	assign DA_PORT[5] = gp[15]; // N17; // DADB5 pin 8
//	assign DA_PORT[3] = gp[16]; // N16; // DADB3 pin 10
//	assign DA_PORT[1] = gp[17]; // L16; // DADB1 pin 12
							            // N/C   pin 14

	// DACLK pin 5
//	assign DA_PORT[6] = gn[15]; // P16; // DADB6 pin 7
//	assign DA_PORT[4] = gn[16]; // M17; // DADB4 pin 9
//	assign DA_PORT[2] = gn[17]; // L17; // DADB2 pin 11
//	assign DA_PORT[0] = gn[18]; // G18; // DADB0 pin 13

//	assign AD_PORT[1] = gp[21]; // C18; // ADDB1 pin 22
//	assign AD_PORT[3] = gp[22]; // B15; // ADDB3 pin 24
//	assign AD_PORT[5] = gp[23]; // B17; // ADDB5 pin 26
//	assign AD_PORT[7] = gp[24]; // C16; // ADDB7 pin 28

//	assign AD_PORT[3] = gn[21]; // D17; // ADDB0 pin 21
//	assign AD_PORT[2] = gn[22]; // C15; // ADDB2 pin 23
//	assign AD_PORT[1] = gn[23]; // C17; // ADDB4 pin 25
//	assign AD_PORT[0] = gn[24]; // D14; // ADDB6 pin 27
	// ADCLK PIN 29

	localparam ctr_width = 32;
    reg [ctr_width-1:0] ctr = 0;

	always @(posedge i_clk) begin
		ctr <= ctr + 1;
		o_value[7:0] <= AD_PORT[7:0] && ctr[7:0];
	  // DA_PORT[7:0] <= AD_PORT[7:0];
	end

endmodule

