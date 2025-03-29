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