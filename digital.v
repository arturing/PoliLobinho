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


module fluxo_dados(
    input clock,
    input botao,

    input e_seed_reg,
    input zera_CS, 
    input rst_global,
    input zera_CJ,
    input inc_jogador,

    output CJ_fim,
    output [9:0] jogo_atual,
    output [1:0] classe_atual,
    output [2:0] jogador_atual,

    output [4:0] db_seed
);

// Lógica de Seed

wire [9:0] seed_jogo, jogo;
wire [4:0] seed_addr;
wire inc_seed;
wire [2:0] jogador;

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
    .class(classe_atual)
);

assign jogo_atual = jogo;
assign db_seed = seed_addr;
assign jogador_atual = jogador;

// Fim Lógica de Seed


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