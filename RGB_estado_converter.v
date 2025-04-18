module RGB_estado_converter (
		input [4:0] db_estado,
		input clock,
		output reg [2:0] RGB_estado
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
	 
	 parameter RED    = 3'b100;
	 parameter GREEN  = 3'b010;
	 parameter BLUE   = 3'b001;
	 
	 parameter PURPLE = 3'b101;
	 parameter YELLOW = 3'b101;
	 parameter CYAN   = 3'b011;
	 
	 parameter WHITE  = 3'b111;
	 
	 always @(posedge clock) begin
        case (db_estado)
            PREPARA_NOITE: RGB_estado = PURPLE;
            PROXIMO_JOGADOR_NOITE : RGB_estado = PURPLE;
            TURNO_NOITE: RGB_estado = PURPLE;
            FIM_NOITE: RGB_estado = PURPLE;
            DELAY_NOITE: RGB_estado = PURPLE;
            AVALIAR_ELIMINACAO_NOITE: RGB_estado = PURPLE;
            DIA_INICIO: RGB_estado = CYAN;
            DIA_DISCUSSAO: RGB_estado = CYAN;
            DIA_VOTO: RGB_estado = BLUE;
            LOBO_PERDEU: RGB_estado = GREEN;
				LOBO_GANHOU: RGB_estado = RED;
            CHECAR_LOBO_GANHOU_NOITE: RGB_estado = PURPLE;
				CHECAR_LOBO_GANHOU_DIA: RGB_estado = CYAN;
            default:     RGB_estado = 3'b000;
        endcase
    end
endmodule