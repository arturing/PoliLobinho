module unidade_controle(
        input clock,
        input reset,
        input jogar,
        input passa,
        input CJ_fim,
        input jogador_vivo,
        input acertou,
        input votou,
        input sinal_lobo_ganhou,
        input jogou,

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

        output reg [4:0] db_estado,
        output reg voto,
        output reg morra
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
    parameter CHECAR_VIVO = 5'd12;
    parameter DIA_INICIO = 5'd13;
    parameter DIA_DISCUSSAO = 5'd14;
    parameter DIA_VOTO = 5'd15;
    parameter PROCESSA_VOTO = 5'd16;

    parameter MATARAM_O_MARUITI = 5'd17;
    parameter CHECAR_LOBO_GANHOU_NOITE = 5'd18;
    parameter CHECAR_LOBO_GANHOU_DIA = 5'd19;

    parameter LOBO_PERDEU = 5'd20;
    parameter LOBO_GANHOU = 5'd21;

    reg [4:0] Eatual, Eprox;
    // reg [2:0] contador_mortes = 0;
    // wire [2:0] contador_mortes_calc;
    // assign contador_mortes_calc = mortes[0] + mortes[1] + mortes[2] + mortes[3] + mortes[4];

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
            PREPARA_NOITE: Eprox = CHECAR_VIVO;
            PROXIMO_JOGADOR_NOITE : Eprox = CHECAR_VIVO;
            CHECAR_VIVO : Eprox = (jogador_vivo) ? DELAY_NOITE : ((CJ_fim) ? FIM_NOITE : PROXIMO_JOGADOR_NOITE);
            DELAY_NOITE: Eprox = (passa) ? TURNO_NOITE : DELAY_NOITE;
            TURNO_NOITE: Eprox = (passa && jogou) ? ((CJ_fim) ? FIM_NOITE : PROXIMO_JOGADOR_NOITE ) : TURNO_NOITE;
            FIM_NOITE: Eprox = AVALIAR_ELIMINACAO_NOITE;
            AVALIAR_ELIMINACAO_NOITE: Eprox = ANUNCIAR_MORTE;
            // ANUNCIAR_MORTE: Eprox = (passa) ? DIA_INICIO : ANUNCIAR_MORTE;
            ANUNCIAR_MORTE: Eprox = (passa) ? CHECAR_LOBO_GANHOU_NOITE : ANUNCIAR_MORTE;

            CHECAR_LOBO_GANHOU_NOITE: Eprox = (sinal_lobo_ganhou) ? LOBO_GANHOU : DIA_INICIO;
            CHECAR_LOBO_GANHOU_DIA: Eprox = (sinal_lobo_ganhou) ? LOBO_GANHOU : PREPARA_NOITE;

            
            DIA_INICIO: Eprox = DIA_DISCUSSAO;
            DIA_DISCUSSAO: Eprox = (passa) ? DIA_VOTO : DIA_DISCUSSAO;
            DIA_VOTO: Eprox = (passa && votou) ? PROCESSA_VOTO : DIA_VOTO;
            PROCESSA_VOTO: Eprox = (acertou) ? LOBO_PERDEU : MATARAM_O_MARUITI;
            // MATARAM_O_MARUITI: Eprox = PREPARA_NOITE;
            MATARAM_O_MARUITI: Eprox = CHECAR_LOBO_GANHOU_DIA;


            // CHECAR_LOBO_GANHOU_NOITE: begin
            //     // contador_mortes = mortes[0] + mortes[1] + mortes[2] + mortes[3] + mortes[4];
            //     // #1
            //     if (contador_mortes_calc == 3'd3)
            //         Eprox = LOBO_GANHOU;
            //     else
            //         Eprox = PREPARA_NOITE;
            // end

            LOBO_PERDEU: Eprox = (jogar) ? RESETA_TUDO : LOBO_PERDEU;
            LOBO_GANHOU: Eprox = (jogar) ? RESETA_TUDO : LOBO_GANHOU;
            
            
    
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

        reset_Convertor = (Eatual == INICIAL || Eatual == RESETA_TUDO || Eatual == PROXIMO_JOGADOR_NOITE || Eatual == DELAY_NOITE || Eatual == DIA_DISCUSSAO);

        avaliar_eliminacao = (Eatual == AVALIAR_ELIMINACAO_NOITE);
        
        inc_seed = (Eatual == PREPARA_JOGO);

        e_seed_reg = (Eatual == ARMAZENA_JOGO);

        inc_jogador = (Eatual == PROXIMO_JOGADOR_NOITE);
        
        voto = (Eatual == DIA_VOTO);
        
        morra = (Eatual == MATARAM_O_MARUITI);


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
            DIA_INICIO: db_estado = DIA_INICIO;
            DIA_DISCUSSAO: db_estado = DIA_DISCUSSAO;
            DIA_VOTO: db_estado = DIA_VOTO;
            PROCESSA_VOTO: db_estado = PROCESSA_VOTO;
            MATARAM_O_MARUITI: db_estado = MATARAM_O_MARUITI;
            LOBO_PERDEU: db_estado = LOBO_PERDEU;
            CHECAR_LOBO_GANHOU_NOITE: db_estado = CHECAR_LOBO_GANHOU_NOITE;
            default:     db_estado = 5'b11111; //erro
        endcase
    end


endmodule