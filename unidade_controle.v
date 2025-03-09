module unidade_controle(
    input clock,
    input reset,
    input jogar,
    input passa,
);

    output reg e_seed_reg,
    output reg zera_CS, 
    output reg rst_global,

    output reg db_estado
);

parameter INICIAL = 5'd0;
parameter RESETA_TUDO = 5'd1;
parameter PREPARA_JOGO = 5'd2;
parameter ARMAZENA_JOGO = 5'd3;
parameter PREPARA_JOGO_2 = 5'd4;
parameter PREPARA_NOITE = 5'd45;

reg [4:0] Eatual, Eprox;

// Memoria de estado
always @(posedge clock or posedge reset) begin
    if (reset)
        Eatual <= inicial;
    else
        Eatual <= Eprox;
end


always@(posedge clock) begin
    case(Eatual)
        INICIAL: Eprox = (jogar) ? RESETA_TUDO : INICIAL;
        RESETA_TUDO: Eprox = PREPARA_JOGO;
        PREPARA_JOGO: Eprox = (passa) ? ARMAZENA_JOGO : PREPARA_JOGO;
        ARMAZENA_JOGO: Eprox = PREPARA_JOGO_2;
        PREPARA_JOGO_2: Eprox = PREPARA_NOITE; 

    endcase
end
  
always @* begin
    rst_global = (Eatual == INICIAL || Eatual == RESETA_TUDO);  

    zera_CS = (Eatual == INICIAL || Eatual == RESETA_TUDO);

    e_seed_reg = (Eatual == ARMAZENA_JOGO);
end

        case (Eatual)
            INICIAL: db_estado = INICIAL;
            RESETA_TUDO: db_estado = RESETA_TUDO;
            PREPARA_JOGO: db_estado = PREPARA_JOGO;
            ARMAZENA_JOGO: db_estado = ARMAZENA_JOGO; 
            PREPARA_JOGO_2: db_estado = PREPARA_JOGO_2;
            PREPARA_NOITE: db_estado = PREPARA_NOITE;
            default:     db_estado = 5'b11111; //erro
        endcase


endmodule