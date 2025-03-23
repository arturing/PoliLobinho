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