module fluxo_dados(
    input clock,
//    input botao,

    input e_seed_reg,
    input zera_CS, 
    input rst_global,
    input zera_CJ,
    input inc_jogador,
	 input mostra_classe,
	 input inc_seed,

    output CJ_fim,
    output [9:0] jogo_atual,
    output [1:0] classe_atual,
    output [2:0] jogador_atual,

    output [4:0] db_seed
);

// Lógica de Seed

wire [9:0] seed_jogo, jogo;
wire [4:0] seed_addr;
wire [2:0] jogador;
wire [1:0] w_classe_atual;

//edge_detector DETECTA_SEED(
//    .clock(clock),
//    .reset(rst_global),
//    .sinal(botao),
//    .pulso(toggle)
//);

contador_m #(.M(20), .N(5)) CONTA_SEED(
   .clock(clock),
   .zera(zera_CS),
   .conta(inc_seed),
   .Q(seed_addr),
   .fim()
);

seed_rom SEED_MEM(
    .clock(clock),
    .address(seed_addr),
    .data_out(seed_jogo)
);

registrador_M #(.N(10)) REG_SEED(
    .clock(clock),
    .clear(rst_global),
    .enable(e_seed_reg),
    .D(seed_jogo),
    .Q(jogo)
);

contador_m #(.M(5), .N(3)) CONTA_JOGADOR(
   .clock(clock),
   .zera(zera_CJ),
   .conta(inc_jogador),
   .Q(jogador),
   .fim(CJ_fim)
);

class_parser CLASSE(
    .clock(clock),
    .jogador(jogador),
    .jogo(jogo),
    .class(w_classe_atual)
);

assign classe_atual = (mostra_classe) ? w_classe_atual : 2'b11;

assign jogo_atual = jogo;
assign db_seed = seed_addr;
assign jogador_atual = jogador;

// Fim Lógica de Seed


endmodule