module unidade_controle(
    input clock,
    input reset,
    input jogar,
    input passa,
    input CJ_fim,

    output reg e_seed_reg,
    output reg zera_CS,
    output reg rst_global,
    output reg zera_CJ,
    output reg inc_jogador,

    output reg [4:0] db_estado
);

parameter INICIAL = 5'd0;
parameter RESETA_TUDO = 5'd1;
parameter PREPARA_JOGO = 5'd2;
parameter ARMAZENA_JOGO = 5'd3;
parameter PREPARA_JOGO_2 = 5'd4;
parameter PREPARA_NOITE = 5'd5;
parameter PROXIMO_JOGADOR_NOITE = 5'd6;
parameter TURNO_NOITE = 5'd7;
parameter FIM_NOITE = 5'd8;

reg [4:0] Eatual, Eprox;

// Memoria de estado
always @(posedge clock or posedge reset) begin
    if (reset)
        Eatual <= INICIAL;
    else
        Eatual <= Eprox;
end


// Logica de proximo estado
always@(posedge clock) begin
    case(Eatual)
        INICIAL: Eprox = (jogar) ? RESETA_TUDO : INICIAL;
        RESETA_TUDO: Eprox = PREPARA_JOGO;
        PREPARA_JOGO: Eprox = (passa) ? ARMAZENA_JOGO : PREPARA_JOGO;
        ARMAZENA_JOGO: Eprox = PREPARA_JOGO_2;
        PREPARA_JOGO_2: Eprox = PREPARA_NOITE;
        PREPARA_NOITE: Eprox = PROXIMO_JOGADOR_NOITE;
        PROXIMO_JOGADOR_NOITE : Eprox = TURNO_NOITE;
        TURNO_NOITE: Eprox = (passa) ? ((CJ_fim) ? FIM_NOITE : PROXIMO_JOGADOR_NOITE ) : TURNO_NOITE;
        FIM_NOITE: Eprox = FIM_NOITE;

        default: Eprox = INICIAL; 
    endcase
end


//Logica de saida (maquina Moore)
always @* begin
    rst_global = (Eatual == INICIAL || Eatual == RESETA_TUDO);  

    zera_CS = (Eatual == INICIAL || Eatual == RESETA_TUDO);

    zera_CJ = (Eatual == PREPARA_NOITE);

    e_seed_reg = (Eatual == ARMAZENA_JOGO);

    inc_jogador = (Eatual == PROXIMO_JOGADOR_NOITE);


end

always @* begin
	db_estado = Eatual;
end


endmodule