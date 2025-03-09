module PoliLobinho(
	input  clock,
	input botao,
	input reset,
	input jogar,
	input passa,
	
	output [4:0] db_estado,
    output [4:0] db_seed,

    output [9:0] jogo_atual
);

wire e_seed_reg;
wire zera_CS;
wire rst_global;


fluxo_dados FD(
	.clock(clock),
	.botao(botao),

	.e_seed_reg(e_seed_reg),
	.zera_CS(zera_CS),
	.rst_global(rst_global),
    .jogo_atual(jogo_atual),
    .db_seed(db_seed)

);

unidade_controle UC(
	.clock(clock),
	.reset(reset),
	.jogar(jogar),
	.passa(passa),
	.e_seed_reg(e_seed_reg),
	.zera_CS(zera_CS),
	.rst_global(rst_global),
	.db_estado(db_estado)
);

endmodule