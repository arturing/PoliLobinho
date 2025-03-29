module PoliLobinho(
	input clock,
	input clock_10k,
	input pular,
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
	 output [6:0] db_jogador_escolhido,
	 output [4:0] db_mortes,
	 output db_clock,
	 //output ganhamo,
	 //output votaram,
	 output votacao,
	 output vitoria_lobo,
	 output vitoria_cidadao,
	 output timeout,
	 output [2:0] db_funcoes
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
wire w_pular;
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
wire reset_Pular;

wire w_acertou, w_votacao, w_morra, w_votou;
wire jogou;
////////////////////////// mudei aqui
wire sinal_lobo_ganhou;
wire zera_CT, discussao;

wire [6:0] w_db_jogador_atual;
wire [6:0] w_db_jogador_escolhido;

assign db_clock = clock;
assign w_botoes_jogadores = ~botoes_jogadores;
assign w_pular = !pular;
assign w_reset = !reset;
assign w_jogar = !jogar;
assign w_passa = !passa;
//assign ganhamo = w_acertou;
//assign votaram = w_votou;
assign votacao = w_votacao;

assign db_jogador_atual = ~w_db_jogador_atual;
assign db_jogador_escolhido = ~w_db_jogador_escolhido;


edge_detector DETECTA_PASSA(
    .clock(clock),
    .reset(rst_global),
    .sinal(w_passa),
    .pulso(pulso_passa)
);

regJogadorConvertor CONVERTE_JOGADOR(
	.clock(clock),
	.reset(reset_Convertor),
	.botoes_jogadores({w_pular, w_botoes_jogadores}),
	.jogador_escolhido(jogador_escolhido)
);

fluxo_dados FD(
	.clock(clock),
	.clock_10k(clock_10k),
//	.botao(w_botao),

	.e_seed_reg(e_seed_reg),
	.zera_CS(zera_CS),
	.zera_CT(zera_CT),
	.rst_global(rst_global),
	.zera_CJ(zera_CJ),
	.inc_jogador(inc_jogador),
	.inc_seed(w_inc_seed),
	.avaliar_eliminacao(avaliar_eliminacao),
	.voto(w_votacao),
	.morra(w_morra),
	.reset_Pular(reset_Pular),
	.discussao(discussao),

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
	.timeout(timeout),

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
	.reset_Pular(reset_Pular),
	.zera_CT(zera_CT),
	.discussao(discussao),
	
	.db_estado(db_estado),
	.votacao(w_votacao),
	.vitoria_lobo(vitoria_lobo),
	.vitoria_cidadao(vitoria_cidadao),
	.morra(w_morra)
);

hexa7seg disp0 (
	.hexa({2'b0,classe_atual}),
	.display(db_classe_atual)

);

hexa7seg disp1 (
	.hexa({1'b0,jogador_atual}),
	.display(w_db_jogador_atual)

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

hexa7seg disp6 (
	.hexa({1'b0,jogador_escolhido}),
	.display(w_db_jogador_escolhido)

);

class_to_led_converter CONVERTER_LED(
	.class(classe_atual),
	.LEDs(db_funcoes)	
);

endmodule

module class_to_led_converter (
	input[1:0] class,
	output reg [2:0] LEDs
);

parameter aldeao = 2'd0;
parameter lobo = 2'd1;
parameter medico = 2'd2;

always@* begin
	case(class)
		aldeao: LEDs = 3'b001; 
		lobo: LEDs = 3'b100;
		medico: LEDs = 3'b010;
		default: LEDs = 3'b000;
	endcase
end
endmodule
module adder_3b( 
    input [2:0] a, b,
    input cin,
    output [2:0] cout,
    output [2:0] sum );
    
    full_adder inst_full_adder0(
        .a(a[0]),
        .b(b[0]),
        .cin(cin),
        .sum(sum[0]),
        .cout(cout[0])
    );
    
   full_adder inst_full_adder1(
       .a(a[1]),
       .b(b[1]),
       .cin(cout[0]),
       .sum(sum[1]),
       .cout(cout[1])
    );
    
    full_adder inst_full_adder2(
        .a(a[2]),
        .b(b[2]),
        .cin(cout[1]),
        .sum(sum[2]),
        .cout(cout[2])
    );

endmodule

module class_parser(
    input clock,
    input [2:0] jogador,
    input [9:0] jogo,
    output reg [1:0] class
);

always@(posedge clock) begin
    case(jogador)
        3'd0: class = jogo[9:8];
        3'd1: class = jogo[7:6]; 
        3'd2: class = jogo[5:4];
        3'd3: class = jogo[3:2]; 
        3'd4: class = jogo[1:0]; 
        default: class = 2'b11;  //Erro
    endcase
end

endmodule
module conta_mortes (
	input [4:0]mortes,
    output [2:0]count 
);
	
	wire [2:0] adder0_out, adder1_out, adder2_out, adder3_out;
	
    adder_3b adder0 (
        .a({2'b0, mortes[0]}),
		  .b({2'b0, mortes[1]}),
		  .cin(1'b0),
		  .sum(adder0_out)
		  
    );
	 
    adder_3b adder1 (
        .a({2'b0, mortes[2]}),
		  .b({2'b0, mortes[3]}),
		  .cin(1'b0),
		  .sum(adder1_out)
		  
    );	
	 
	 adder_3b adder2 (
        .a(adder0_out),
		  .b(adder1_out),
		  .cin(1'b0),
		  .sum(adder2_out)
		  
    );
	 
	 
	 
	 adder_3b adder3 (
        .a(adder2_out),
		  .b({2'b0, mortes[4]}),
		  .cin(1'b0),
		  .sum(adder3_out)
		  
    );
	 
	 assign count = adder3_out;
    
endmodule 

/*---------------Laboratorio Digital-------------------------------------
 * Arquivo   : contador_m.v
 * Projeto   : Experiencia 4 - Desenvolvimento de Projeto de 
 *                             Circuitos Digitais em FPGA
 *-----------------------------------------------------------------------
 * Descricao : contador binario, modulo m, com parametros 
 *             M (modulo do contador) e N (numero de bits),
 *             sinais para clear assincrono (zera_as) e sincrono (zera_s)
 *             e saidas de fim e meio de contagem
 *             
 *-----------------------------------------------------------------------
 * Revisoes  :
 *     Data        Versao  Autor             Descricao
 *     30/01/2024  1.0     Edson Midorikawa  criacao
 *     16/01/2025  1.1     Edson Midorikawa  revisao
 *-----------------------------------------------------------------------
 */

module contador_m #(parameter M=100, N=7)
  (
   input  wire          clock,
   input  wire          zera,
   input  wire          conta,
   output reg  [N-1:0]  Q,
   output reg           fim
  );

  always @(posedge clock or posedge zera) begin
    if (zera) begin
      Q <= 0;
    end else if (clock) begin
	 if (conta) begin
        if (Q == M-1) begin
          Q <= 0;
        end else begin
          Q <= Q + 1'b1;
        end
		end
	 end
  end

  // Saidas
  always @ (Q)
      if (Q == M-1)   fim = 1;
      else            fim = 0;

endmodule

/* ------------------------------------------------------------------------
 *  Arquivo   : edge_detector.v
 *  Projeto   : Experiencia 4 - Desenvolvimento de Projeto de
 *                              Circuitos Digitais com FPGA
 * ------------------------------------------------------------------------
 *  Descricao : detector de borda
 *              gera um pulso na saida de 1 periodo de clock
 *              a partir da detecao da borda de subida sa entrada
 * 
 *              sinal de reset ativo em alto
 * 
 *              > codigo adaptado a partir de codigo VHDL disponivel em
 *                https://surf-vhdl.com/how-to-design-a-good-edge-detector/
 * ------------------------------------------------------------------------
 *  Revisoes  :
 *      Data        Versao  Autor             Descricao
 *      26/01/2024  1.0     Edson Midorikawa  versao inicial
 * ------------------------------------------------------------------------
 */
 
module edge_detector (
    input  clock,
    input  reset,
    input  sinal,
    output pulso
);

    reg reg0;
    reg reg1;

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            reg0 <= 1'b0;
            reg1 <= 1'b0;
        end else if (clock) begin
            reg0 <= sinal;
            reg1 <= reg0;
        end
    end

    assign pulso = ~reg1 & reg0;

endmodule

/*--------------------------------------------------------------
 * Arquivo   : estado7seg.v
 * Projeto   : Jogo do Desafio da Memoria
 * -------------------------------------------------------------
 * Descricao : decodificador estado para 
 *             display de 7 segmentos 
 * 
 * entrada: estado - codigo binario de 5 bits
 * saida: display - codigo de 7 bits para display de 7 segmentos
 * ----------------------------------------------------------------
 * dica de uso: mapeamento para displays da placa DE0-CV
 *              bit 6 mais significativo é o bit a esquerda
 *              p.ex. display(6) -> HEX0[6] ou HEX06
 * ----------------------------------------------------------------
 * Revisoes  :
 *     Data        Versao  Autor             	Descricao
 *     09/02/2021  1.0     Edson Midorikawa  	criacao
 *     30/01/2025  2.0     Edson Midorikawa  	revisao p/ Verilog
 * 	 11/02/2025  2.1 		Augusto Vaccarelli 	revisao
 * ----------------------------------------------------------------
 */

module estado7seg (estado, display);
    input      [4:0] estado;
    output reg [6:0] display;


always @(*) begin
    case (estado)
        5'b00000: display = 7'b1000000;  // 0
        5'b00001: display = 7'b1111001;  // 1
        5'b00010: display = 7'b0100100;  // 2
        5'b00011: display = 7'b0110000;  // 3
        5'b00100: display = 7'b0011001;  // 4
        5'b00101: display = 7'b0010010;  // 5
        5'b00110: display = 7'b0000010;  // 6
        5'b00111: display = 7'b1111000;  // 7
        5'b01000: display = 7'b0000000;  // 8
        5'b01001: display = 7'b0010000;  // 9
        5'b01010: display = 7'b0001000;  // A
        5'b01011: display = 7'b0000011;  // B
        5'b01100: display = 7'b1000110;  // C
        5'b01101: display = 7'b0100001;  // D
        5'b01110: display = 7'b0000110;  // E
        5'b01111: display = 7'b0001110;  // F
        5'b10000: display = 7'b1111110;  // 10
        5'b10001: display = 7'b1111101;  // 11
        5'b10010: display = 7'b1111011;  // 12
        5'b10011: display = 7'b1110111;  // 13
        5'b10100: display = 7'b1101111;  // 14
        5'b10101: display = 7'b1011111;  // 15
        5'b10110: display = 7'b0111111;  // 16
        5'b10111: display = 7'b1111100;  // 17
        5'b11000: display = 7'b1110011;  // 18
        5'b11001: display = 7'b1100111;  // 19
        5'b11010: display = 7'b1001111;  // 1A
        5'b11011: display = 7'b0011111;  // 1B
        5'b11100: display = 7'b1110001;  // 1C
        5'b11101: display = 7'b1100011;  // 1D
        5'b11110: display = 7'b1000111;  // 1E
        5'b11111: display = 7'b0001111;  // 1F
        default:  display = 7'b1111111;
    endcase
end

endmodule



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
	 
	 contador_m #(.M(10000), .N(14)) CONTA_SEGUNDOS(
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
module full_adder (
	input a, b, cin,
    output sum, cout
);
    assign sum = a ^ b ^ cin;
    assign cout =a&b | a&cin | b&cin;
    
endmodule 
/* ----------------------------------------------------------------
 * Arquivo   : hexa7seg.v
 * Projeto   : Experiencia 2 - Um Fluxo de Dados Simples
 *--------------------------------------------------------------
 * Descricao : decodificador hexadecimal para 
 *             display de 7 segmentos 
 * 
 * entrada : hexa - codigo binario de 4 bits hexadecimal
 * saida   : sseg - codigo de 7 bits para display de 7 segmentos
 *
 * baseado no componente bcd7seg.v da Intel FPGA
 *--------------------------------------------------------------
 * dica de uso: mapeamento para displays da placa DE0-CV
 *              bit 6 mais significativo é o bit a esquerda
 *              p.ex. sseg(6) -> HEX0[6] ou HEX06
 *--------------------------------------------------------------
 * Revisoes  :
 *     Data        Versao  Autor             Descricao
 *     24/12/2023  1.0     Edson Midorikawa  criacao
 *--------------------------------------------------------------
 */

module hexa7seg (hexa, display);
    input      [3:0] hexa;
    output reg [6:0] display;

    /*
     *    ---
     *   | 0 |
     * 5 |   | 1
     *   |   |
     *    ---
     *   | 6 |
     * 4 |   | 2
     *   |   |
     *    ---
     *     3
     */
        
    always @(hexa)
    case (hexa)
        4'h0:    display = 7'b1000000;
        4'h1:    display = 7'b1111001;
        4'h2:    display = 7'b0100100;
        4'h3:    display = 7'b0110000;
        4'h4:    display = 7'b0011001;
        4'h5:    display = 7'b0010010;
        4'h6:    display = 7'b0000010;
        4'h7:    display = 7'b1111000;
        4'h8:    display = 7'b0000000;
        4'h9:    display = 7'b0010000;
        4'ha:    display = 7'b0001000;
        4'hb:    display = 7'b0000011;
        4'hc:    display = 7'b1000110;
        4'hd:    display = 7'b0100001;
        4'he:    display = 7'b0000110;
        4'hf:    display = 7'b0001110;
        default: display = 7'b1111111;
    endcase
endmodule

module regJogadorConvertor (
    input clock,
    input [5:0] botoes_jogadores,
    input reset,
    
    output reg [2:0] jogador_escolhido
);

wire w_OR_botoes;

assign w_OR_botoes = |botoes_jogadores;

always @(posedge clock or posedge reset) begin
	if (reset) jogador_escolhido = 3'b111;
    else if (w_OR_botoes) begin
        case(botoes_jogadores)
            6'b000001 : jogador_escolhido = 3'b000; //jogador 0
            6'b000010 : jogador_escolhido = 3'b001; //jogador 1
            6'b000100 : jogador_escolhido = 3'b010; //jogador 2
            6'b001000 : jogador_escolhido = 3'b011; //jogador 3
            6'b010000 : jogador_escolhido = 3'b100; //jogador 4
            6'b100000 : jogador_escolhido = 3'b101; //Pular
            default   : jogador_escolhido = 3'b111; //catch-all
        endcase
    end
end

endmodule
//------------------------------------------------------------------
// Arquivo   : registrador_4.v
// Projeto   : Experiencia 3 - Projeto de uma Unidade de Controle 
//------------------------------------------------------------------
// Descricao : Registrador de 4 bits
//             
//------------------------------------------------------------------
// Revisoes  :
//     Data        Versao  Autor             Descricao
//     14/12/2023  1.0     Edson Midorikawa  versao inicial
//------------------------------------------------------------------
//
module registrador_M #(parameter N = 4) (
    input        clock,
    input        clear,
    input        enable,
    input  [N-1:0] D,
    output [N-1:0] Q
);

    reg [N-1:0] IQ;

    always @(posedge clock or posedge clear) begin
        if (clear)
            IQ <= 0;
        else if (enable)
            IQ <= D;
    end

    assign Q = IQ;

endmodule
/*
00 -> Aldeão
01 -> Lobo
10 -> Médico
*/

module seed_rom(
    input clock,
    input [4:0] address,
    output reg [9:0] data_out
);

always@(posedge clock) begin
    case(address)
        5'd0: data_out = 10'b01_10_00_00_00; // Jogador 0 é o lobo, Jogador 1 é o médico
        5'd1: data_out = 10'b01_00_10_00_00; // Jogador 0 é o lobo, Jogador 2 é o médico
        5'd2: data_out = 10'b01_00_00_10_00; // Jogador 0 é o lobo, Jogador 3 é o médico
        5'd3: data_out = 10'b01_00_00_00_10; // Jogador 0 é o lobo, Jogador 4 é o médico
        5'd4: data_out = 10'b10_01_00_00_00; // Jogador 1 é o lobo, Jogador 0 é o médico
        5'd5: data_out = 10'b00_01_10_00_00; // Jogador 1 é o lobo, Jogador 2 é o médico
        5'd6: data_out = 10'b00_01_00_10_00; // Jogador 1 é o lobo, Jogador 3 é o médico
        5'd7: data_out = 10'b00_01_00_00_10; // Jogador 1 é o lobo, Jogador 4 é o médico
        5'd8: data_out = 10'b10_00_01_00_00; // Jogador 2 é o lobo, Jogador 0 é o médico
        5'd9: data_out = 10'b00_10_01_00_00; // Jogador 2 é o lobo, Jogador 1 é o médico
        5'd10: data_out = 10'b00_00_01_10_00; // Jogador 2 é o lobo, Jogador 3 é o médico
        5'd11: data_out = 10'b00_00_01_00_10; // Jogador 2 é o lobo, Jogador 4 é o médico
        5'd12: data_out = 10'b10_00_00_01_00; // Jogador 3 é o lobo, Jogador 0 é o médico
        5'd13: data_out = 10'b00_10_00_01_00; // Jogador 3 é o lobo, Jogador 1 é o médico
        5'd14: data_out = 10'b00_00_10_01_00; // Jogador 3 é o lobo, Jogador 2 é o médico
        5'd15: data_out = 10'b00_00_00_01_10; // Jogador 3 é o lobo, Jogador 4 é o médico
        5'd16: data_out = 10'b10_00_00_00_01; // Jogador 4 é o lobo, Jogador 0 é o médico
        5'd17: data_out = 10'b00_10_00_00_01; // Jogador 4 é o lobo, Jogador 1 é o médico
        5'd18: data_out = 10'b00_00_10_00_01; // Jogador 4 é o lobo, Jogador 2 é o médico
        5'd19: data_out = 10'b00_00_00_10_01; // Jogador 4 é o lobo, Jogador 3 é o médico
        default: data_out = 10'b01_10_00_00_00;
    endcase
end

endmodule
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
        output reg reset_Pular,

        output reg [4:0] db_estado,
        output reg votacao,
		  output reg vitoria_lobo,
		  output reg vitoria_cidadao,
		  output reg zera_CT,
          output reg discussao,
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
		  
		zera_CT = (Eatual == INICIAL || Eatual == RESETA_TUDO || Eatual == DIA_INICIO || Eatual == DIA_VOTO);

        discussao = (Eatual == DIA_DISCUSSAO);
        
        mostra_classe = (Eatual == TURNO_NOITE);

        processar_acao = (Eatual == TURNO_NOITE);

        zera_CJ = (Eatual == PREPARA_NOITE || Eatual == INICIAL || Eatual == RESETA_TUDO);

        reset_Convertor = (Eatual == INICIAL || Eatual == RESETA_TUDO || Eatual == PROXIMO_JOGADOR_NOITE || Eatual == DELAY_NOITE || Eatual == DIA_DISCUSSAO);

        reset_Pular = (Eatual == INICIAL || Eatual == RESETA_TUDO || Eatual == FIM_NOITE || Eatual == PREPARA_NOITE);

        avaliar_eliminacao = (Eatual == AVALIAR_ELIMINACAO_NOITE);
        
        inc_seed = (Eatual == PREPARA_JOGO);

        e_seed_reg = (Eatual == ARMAZENA_JOGO);

        inc_jogador = (Eatual == PROXIMO_JOGADOR_NOITE);
        
        votacao = (Eatual == DIA_VOTO);
        
        morra = (Eatual == MATARAM_O_MARUITI);
		  
		  vitoria_lobo = (Eatual == LOBO_GANHOU);
		  
		  vitoria_cidadao = (Eatual == LOBO_PERDEU);


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
