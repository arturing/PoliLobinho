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
	output reg inc_seed,
	output reg mostra_classe,
    output reg processar_acao,
    output reg reset_Convertor,
    output reg avaliar_eliminacao,

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
parameter DELAY_NOITE = 5'd9;
parameter AVALIAR_ELIMINACAO_NOITE = 5'd10;
parameter ANUNCIAR_MORTE = 5'd11;

reg [4:0] Eatual, Eprox;

// Memoria de estado
always @(posedge clock or posedge reset) begin
    if (reset)
        Eatual <= INICIAL;
    else
        Eatual <= Eprox;
end


// Logica de proximo estado
always @* begin
    case(Eatual)
        INICIAL: Eprox = (jogar) ? RESETA_TUDO : INICIAL;
        RESETA_TUDO: Eprox = PREPARA_JOGO;
        PREPARA_JOGO: Eprox = (passa) ? ARMAZENA_JOGO : PREPARA_JOGO;
        ARMAZENA_JOGO: Eprox = PREPARA_JOGO_2;
        PREPARA_JOGO_2: Eprox = PREPARA_NOITE;
        PREPARA_NOITE: Eprox = DELAY_NOITE;
        PROXIMO_JOGADOR_NOITE : Eprox = DELAY_NOITE;
		DELAY_NOITE: Eprox = (passa) ? TURNO_NOITE : DELAY_NOITE;
        TURNO_NOITE: Eprox = (passa) ? ((CJ_fim) ? FIM_NOITE : PROXIMO_JOGADOR_NOITE ) : TURNO_NOITE;
        FIM_NOITE: Eprox = AVALIAR_ELIMINACAO_NOITE;
        AVALIAR_ELIMINACAO_NOITE: Eprox = ANUNCIAR_MORTE;
        ANUNCIAR_MORTE: Eprox = ANUNCIAR_MORTE;

        default: Eprox = INICIAL; 
    endcase
end


//Logica de saida (maquina Moore)
always @* begin
    rst_global = (Eatual == INICIAL || Eatual == RESETA_TUDO);  

    zera_CS = (Eatual == INICIAL || Eatual == RESETA_TUDO);
	 
	mostra_classe = (Eatual == TURNO_NOITE);

    processar_acao = (Eatual == TURNO_NOITE);

    zera_CJ = (Eatual == PREPARA_NOITE || Eatual == INICIAL || Eatual == RESETA_TUDO);

    reset_Convertor = (Eatual == INICIAL || Eatual == RESETA_TUDO || Eatual == PROXIMO_JOGADOR_NOITE);

    avaliar_eliminacao = (Eatual == AVALIAR_ELIMINACAO_NOITE);
	 
	inc_seed = (Eatual == PREPARA_JOGO);

    e_seed_reg = (Eatual == ARMAZENA_JOGO);

    inc_jogador = (Eatual == PROXIMO_JOGADOR_NOITE);


end

always @* begin
	case (Eatual)
		INICIAL: db_estado = INICIAL;
		RESETA_TUDO: db_estado = RESETA_TUDO;
		PREPARA_JOGO: db_estado = PREPARA_JOGO;
		ARMAZENA_JOGO: db_estado = ARMAZENA_JOGO; 
		PREPARA_JOGO_2: db_estado = PREPARA_JOGO_2;
		PREPARA_NOITE: db_estado = PREPARA_NOITE;
        PROXIMO_JOGADOR_NOITE : db_estado = PROXIMO_JOGADOR_NOITE;
        TURNO_NOITE: db_estado = TURNO_NOITE;
        FIM_NOITE: db_estado = FIM_NOITE;
		DELAY_NOITE: db_estado = DELAY_NOITE;
        AVALIAR_ELIMINACAO_NOITE: db_estado = AVALIAR_ELIMINACAO_NOITE;
        ANUNCIAR_MORTE: db_estado = ANUNCIAR_MORTE;
		default:     db_estado = 5'b11111; //erro
	endcase
end


endmodule