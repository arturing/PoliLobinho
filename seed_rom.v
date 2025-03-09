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
        5'd0: data_out = 01_10_00_00_00; // Jogador 0 é o lobo, Jogador 1 é o médico
        5'd1: data_out = 01_00_10_00_00; // Jogador 0 é o lobo, Jogador 2 é o médico
        5'd2: data_out = 01_00_00_10_00; // Jogador 0 é o lobo, Jogador 3 é o médico
        5'd3: data_out = 01_00_00_00_10; // Jogador 0 é o lobo, Jogador 4 é o médico
        5'd4: data_out = 10_01_00_00_00; // Jogador 1 é o lobo, Jogador 0 é o médico
        5'd5: data_out = 00_01_10_00_00; // Jogador 1 é o lobo, Jogador 2 é o médico
        5'd6: data_out = 00_01_00_10_00; // Jogador 1 é o lobo, Jogador 3 é o médico
        5'd7: data_out = 00_01_00_00_10; // Jogador 1 é o lobo, Jogador 4 é o médico
        5'd8: data_out = 10_00_01_00_00; // Jogador 2 é o lobo, Jogador 0 é o médico
        5'd9: data_out = 00_10_01_00_00; // Jogador 2 é o lobo, Jogador 1 é o médico
        5'd10: data_out = 00_00_01_10_00; // Jogador 2 é o lobo, Jogador 3 é o médico
        5'd11: data_out = 00_00_01_00_10; // Jogador 2 é o lobo, Jogador 4 é o médico
        5'd12: data_out = 10_00_00_01_00; // Jogador 3 é o lobo, Jogador 0 é o médico
        5'd13: data_out = 00_10_00_01_00; // Jogador 3 é o lobo, Jogador 1 é o médico
        5'd14: data_out = 00_00_10_01_00; // Jogador 3 é o lobo, Jogador 2 é o médico
        5'd15: data_out = 00_00_00_01_10; // Jogador 3 é o lobo, Jogador 4 é o médico
        5'd16: data_out = 10_00_00_00_01; // Jogador 4 é o lobo, Jogador 0 é o médico
        5'd17: data_out = 00_10_00_00_01; // Jogador 4 é o lobo, Jogador 1 é o médico
        5'd18: data_out = 00_00_10_00_01; // Jogador 4 é o lobo, Jogador 2 é o médico
        5'd19: data_out = 00_00_00_10_01; // Jogador 4 é o lobo, Jogador 3 é o médico
        default: 5'd0: data_out = 01_10_00_00_00;
    endcase
end

endmodule