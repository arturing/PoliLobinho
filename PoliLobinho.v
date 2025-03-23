module PoliLobinho(
	input clock,
	input [4:0] botoes_jogadores,
	input reset,
	input jogar,
	input passa,
	
	
	
	 output [6:0] db_classe_atual,
	 output [6:0] db_jogador_atual,
	 output [6:0] db_estado_7b,
	 output [6:0] db_seed_7b,
	 output [6:0] db_atacado_7b,
	 output [6:0] db_protegido_7b,
	 output [2:0] db_jogador_escolhido,
	 output [4:0] db_mortes,
	 output db_clock,
	 output ganhamo,
	 output votaram
);

wire e_seed_reg, zera_CS;
wire CJ_fim, zera_CJ, inc_jogador;
wire [4:0] db_estado;
wire [4:0] db_seed;
wire [2:0] jogador_atual;
wire [2:0] jogador_escolhido;
wire [1:0] classe_atual;
wire [9:0] jogo_atual;
wire processar_acao;
wire [4:0] w_botoes_jogadores;
wire w_reset;
wire w_jogar;
wire w_passa;
wire w_mostra_classe;
wire w_inc_seed;
wire [2:0] atacado;
wire [2:0] protegido;
wire reset_Convertor;
wire avaliar_eliminacao;
wire jogador_vivo;

wire w_acertou, w_voto, w_morra, w_votou;
wire jogou;
////////////////////////// mudei aqui
wire sinal_lobo_ganhou;


assign db_clock = clock;
assign w_botoes_jogadores = ~botoes_jogadores;
assign w_reset = !reset;
assign w_jogar = !jogar;
assign w_passa = !passa;
assign db_jogador_escolhido = jogador_escolhido;
assign ganhamo = w_acertou;
assign votaram = w_votou;

edge_detector DETECTA_PASSA(
    .clock(clock),
    .reset(rst_global),
    .sinal(w_passa),
    .pulso(pulso_passa)
);

regJogadorConvertor CONVERTE_JOGADOR(
	.clock(clock),
	.reset(reset_Convertor),
	.botoes_jogadores(w_botoes_jogadores),
	.jogador_escolhido(jogador_escolhido)
);

fluxo_dados FD(
	.clock(clock),
//	.botao(w_botao),

	.e_seed_reg(e_seed_reg),
	.zera_CS(zera_CS),
	.rst_global(rst_global),
	.zera_CJ(zera_CJ),
	.inc_jogador(inc_jogador),
	.inc_seed(w_inc_seed),
	.avaliar_eliminacao(avaliar_eliminacao),
	.voto(w_voto),
	.morra(w_morra),

	.CJ_fim(CJ_fim),
    .jogo_atual(jogo_atual),
	.classe_atual(classe_atual),
    .jogador_atual(jogador_atual),
	.mostra_classe(w_mostra_classe),
	.processar_acao(processar_acao),
	.jogador_escolhido(jogador_escolhido),
	.db_atacado(atacado),
	.db_protegido(protegido),
	.db_mortes(db_mortes),
	.jogador_vivo(jogador_vivo),

    .db_seed(db_seed),
	 .acertou(w_acertou),
	 .votou(w_votou),
	 .jogou(jogou),
    .sinal_lobo_ganhou(sinal_lobo_ganhou)

);

unidade_controle UC(
	.clock(clock),
	.reset(w_reset),
	.jogar(w_jogar),
	.passa(pulso_passa),
	.CJ_fim(CJ_fim),
	.jogador_vivo(jogador_vivo),
	.acertou(w_acertou),
	.votou(w_votou),
	.jogou(jogou),
    .sinal_lobo_ganhou(sinal_lobo_ganhou),

	.e_seed_reg(e_seed_reg),
	.zera_CS(zera_CS),
	.rst_global(rst_global),
	.zera_CJ(zera_CJ),
	.inc_jogador(inc_jogador),
	.mostra_classe(w_mostra_classe),
	.inc_seed(w_inc_seed),
	.processar_acao(processar_acao),
	.reset_Convertor(reset_Convertor),
	.avaliar_eliminacao(avaliar_eliminacao),

	.db_estado(db_estado),
	.voto(w_voto),
	.morra(w_morra)
);

hexa7seg disp0 (
	.hexa({2'b0,classe_atual}),
	.display(db_classe_atual)

);

hexa7seg disp1 (
	.hexa({1'b0,jogador_atual}),
	.display(db_jogador_atual)

);

hexa7seg disp2 (
	.hexa({1'b0,atacado}),
	.display(db_atacado_7b)

);

hexa7seg disp3 (
	.hexa({1'b0,protegido}),
	.display(db_protegido_7b)

);

estado7seg disp4 (
	.estado(db_seed),
	.display(db_seed_7b)

);

estado7seg disp5 (
	.estado(db_estado),
	.display(db_estado_7b)

);

endmodule