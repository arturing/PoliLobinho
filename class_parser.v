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