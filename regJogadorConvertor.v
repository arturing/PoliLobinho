module regJogadorConvertor (
    input clock,
    input [4:0] botoes_jogadores,
    
    output reg [2:0] jogador_escolhido
);

wire w_OR_botoes;

assign w_OR_botoes = |botoes_jogadores;

always @(posedge clock) begin
    if (w_OR_botoes) begin
        case(botoes_jogadores)
            5'b00001 : jogador_escolhido = 3'b000; //jogador 0
            5'b00010 : jogador_escolhido = 3'b001; //jogador 1
            5'b00100 : jogador_escolhido = 3'b010; //jogador 2
            5'b01000 : jogador_escolhido = 3'b011; //jogador 3
            5'b10000 : jogador_escolhido = 3'b100; //jogador 4
            default  : jogador_escolhido = 3'b000; //catch-all
        endcase
    end

end


endmodule