module PoliLobinho(
	input clock,
	input botao,
	input reset,
	input jogar,
	input passa,
	
	output [4:0] db_estado,
    output [4:0] db_seed,
	output [2:0] jogador_atual,
	output [1:0] classe_atual,

    output [9:0] jogo_atual
);

wire e_seed_reg, zera_CS;
wire CJ_fim, zera_CJ, inc_jogador;
wire rst_global;

edge_detector DETECTA_PASSA(
    .clock(clock),
    .reset(rst_global),
    .sinal(passa),
    .pulso(pulso_passa)
);

fluxo_dados FD(
	.clock(clock),
	.botao(botao),

	.e_seed_reg(e_seed_reg),
	.zera_CS(zera_CS),
	.rst_global(rst_global),
	.zera_CJ(zera_CJ),
	.inc_jogador(inc_jogador),

	.CJ_fim(CJ_fim),
    .jogo_atual(jogo_atual),
	.classe_atual(classe_atual),
    .jogador_atual(jogador_atual),

    .db_seed(db_seed)

);

unidade_controle UC(
	.clock(clock),
	.reset(reset),
	.jogar(jogar),
	.passa(pulso_passa),
	.CJ_fim(CJ_fim),

	.e_seed_reg(e_seed_reg),
	.zera_CS(zera_CS),
	.rst_global(rst_global),
	.zera_CJ(zera_CJ),
	.inc_jogador(inc_jogador),

	.db_estado(db_estado)
);

endmodule