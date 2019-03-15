module top(
  input  clk_25mhz
//  inout  [27:0] gn,
//  inout  [27:0] gp
);

	wire i_clk;
	assign i_clk= clk_25mhz;

	always @(posedge clk) begin
	  ctr <= ctr + 1;
	end

	wire [7:0] AD_PORT;
	wire [7:0] DA_PORT;

	assign DA_PORT[7] = U18; // DAD87 pin 6
	assign DA_PORT[5] = N17; // DADB5 pin 8
	assign DA_PORT[3] = N16; // DADB3 pin 10
	assign DA_PORT[1] = L16; // DADB1 pin 12
							 // N/C pin 14

	// DACLK pin 5
	assign DA_PORT[6] = P16; // DADB6 pin 7
	assign DA_PORT[4] = M17; // DADB4 pin 9
	assign DA_PORT[2] = L17; // DADB2 pin 11
	assign DA_PORT[0] = G18; // DADB0 pin 13

	assign AD_PORT[1] = C18; // ADDB1 pin 22
	assign AD_PORT[3] = B15; // ADDB3 pin 24
	assign AD_PORT[5] = B17; // ADDB5 pin 26
	assign AD_PORT[7] = C16; // ADDB7 pin 28

	assign AD_PORT[3] = D17; // ADDB0 pin 21
	assign AD_PORT[2] = C15; // ADDB2 pin 23
	assign AD_PORT[1] = C17; // ADDB4 pin 25
	assign AD_PORT[0] = D14; // ADDB6 pin 27
	// ADCLK PIN 29

	always @(posedge i_clk) begin
	  DA_PORT[7:0] <= AD_PORT[7:0];
	end

endmodule

