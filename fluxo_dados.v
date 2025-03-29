module fluxo_dados(
        input clock,
		  input clock_10k,
    //    input botao,

        input e_seed_reg,
        input zera_CS, 
        input rst_global,
        input zera_CJ,
		  input zera_CT,
        input inc_jogador,
        input mostra_classe,
        input processar_acao,
        input inc_seed,
        input avaliar_eliminacao,
        input [2:0] jogador_escolhido,

        input voto,
        input morra,
        input reset_Pular,
        input discussao,

        output CJ_fim,
		  output timeout,
        output [9:0] jogo_atual,
        output [1:0] classe_atual,
        output [2:0] jogador_atual,

        output [2:0] db_atacado,
        output [2:0] db_protegido,
        output [4:0] db_mortes,
        output jogador_vivo,

        output [4:0] db_seed,
        
        output acertou, 
        output votou,
        output jogou,
        output sinal_lobo_ganhou
    );

    // Lógica de Seed

    wire [9:0] seed_jogo, jogo;
    wire [4:0] seed_addr;
    wire [2:0] jogador;
    wire [1:0] w_classe_atual;
    wire [2:0]contador_mortes;
    reg  [5:0] mortes = 6'b000000;
    reg  [2:0] protegido = 3'b000;
    reg  [2:0] atacado = 3'b000;
    reg  [2:0] medico_posicao = 3'b000;
    reg  [2:0] lobo_posicao = 3'd0;
    reg [2:0] votado = 3'd5;
    reg r_votou = 1'b0;
    reg r_jogou = 1'b0;
	 
	 wire fim_segundo, fim_minuto;

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
	 
	 contador_m #(.M(500), .N(9)) CONTA_SEGUNDOS(
    .clock(clock_10k),
    .zera(zera_CT),
    .conta(discussao),
    .Q(),
    .fim(fim_segundo)
    );
	 
	 contador_m #(.M(60), .N(6)) CONTA_MINUTOS(
    .clock(fim_segundo),
    .zera(zera_CT),
    .conta(discussao),
    .Q(),
    .fim(fim_minuto)
    );
	 
	 contador_m #(.M(3), .N(2)) CONTA_TIMEOUT(
    .clock(fim_minuto),
    .zera(zera_CT),
    .conta(discussao && !timeout),
    .Q(),
    .fim(timeout)
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
	 
	 conta_mortes conta_mortes(
			.mortes(mortes[4:0]),
			.count(contador_mortes)
	 );

    always@(posedge clock) begin
        if (processar_acao) begin
            case(w_classe_atual)
                2'b00 : ;//Fazer nada
                2'b01 : atacado <= jogador_escolhido;
                2'b10 : protegido <= jogador_escolhido;
                default: ;//Fazer nada
            endcase
            
            if (w_classe_atual == 2'b10) medico_posicao <= jogador;
            if (w_classe_atual == 2'd1) lobo_posicao <= jogador;
        end
    end

    always@(posedge clock) begin
        if (rst_global) r_jogou <= 0;
        else if(processar_acao) begin
            case(w_classe_atual)
                2'b00 : if (jogador_escolhido != 3'b111) r_jogou <= 1; else r_jogou <= 0;
                2'b01 : if ((!mortes[jogador_escolhido] && jogador_escolhido != lobo_posicao && jogador_escolhido != 3'b111) || jogador_escolhido == 3'b101) r_jogou <= 1; else r_jogou <= 0;
                2'b10 : if ((!mortes[jogador_escolhido] && jogador_escolhido != 3'b111) || jogador_escolhido == 3'b101) r_jogou <= 1; else r_jogou <= 0;
            endcase
        end

    end

    always@(posedge clock) begin
        if (rst_global) mortes <= 5'b00000;
        else if (avaliar_eliminacao) begin
            if (atacado != protegido || mortes[medico_posicao]) mortes[atacado] <= 1;
        end else if (morra) mortes[votado] <= 1'b1;
        else if (reset_Pular) mortes[5'd5] <= 1'b0;
    end

    always@(posedge clock) begin
        if (rst_global) begin votado <= 5'd5;
            r_votou <= 1'b0;
        end else if (voto) begin
            if (!mortes[jogador_escolhido]) begin
                votado <= jogador_escolhido;
                r_votou <= 1'b1;
                end
            else r_votou <= 1'b0;
        end else if(morra) begin		
                r_votou <= 1'b0;
        end	
        else
            r_votou <= 1'b0;
    end

    assign jogador_vivo = !mortes[jogador];

    assign classe_atual = (mostra_classe) ? w_classe_atual : 2'b11;

    assign jogo_atual = jogo;
    assign db_seed = seed_addr;
    assign jogador_atual = jogador;
    assign db_protegido = protegido;
    assign db_atacado = atacado;
    assign db_mortes = mortes;
    assign acertou = (votado == lobo_posicao);
    assign votou = r_votou;
    assign jogou = r_jogou;
//    assign contador_mortes = mortes[0] + mortes[1] + mortes[2] + mortes[3] + mortes[4];
    assign sinal_lobo_ganhou = (contador_mortes ==  3'd3);

    // Fim Lógica de Seed


endmodule