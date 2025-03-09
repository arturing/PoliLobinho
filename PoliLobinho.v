module PoliLobinho(
	input  clock,
	input [4:0] address,
	
	output [9:0] data_out
);

seed_rom rom(
	.clock(clock),
	.address(address),
	.data_out(data_out)
);

fluxo_dados FD();

unidade_controle UC();

endmodule