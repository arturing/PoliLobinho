module fluxo_dados(
    input clock,
    input botao,

    input e_seed_reg,
    input zera_CS, 
    input rst_global

);

// Lógica de Seed

wire [9:0] seed_jogo, jogo;
wire [4:0] seed_addr;
wire inc_seed;

edge_detector DETECTA_SEED(
    .clock(clock),
    .reset(rst_global),
    .sinal(botao),
    .pulso(inc_seed)
);

contador_m #(.M(20), .N(5)) CONTA_SEED(
   .clock(clock),
   .zera(zera_CS),
   .conta(inc_seed),
   .Q(seed_addr),
   .fim(),
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

// Fim Lógica de Seed


endmodule