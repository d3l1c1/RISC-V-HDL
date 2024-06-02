module unsigned_mul (
    input wire clk,
    input wire [31:0] a_i,
    input wire [31:0] b_i,
    output wire [63:0] res_o
);
		
	wire [31:0] m1,m2,m3,m4;	
	
	multiplier mul1(
	   .a(a_i[15:0]),
	   .b(b_i[15:0]),
	   .res(m1),
	   .clk(clk)
	);	
	
	multiplier mul2(
	   .a(a_i[15:0]),
	   .b(b_i[31:16]),
	   .res(m2),
	   .clk(clk)
	);	
		
	multiplier mul3(
	   .a(a_i[31:16]),
	   .b(b_i[15:0]),
	   .res(m3),
	   .clk(clk)
	);
	
	multiplier mul4(
	   .a(a_i[31:16]),
	   .b(b_i[31:16]),
	   .res(m4),
	   .clk(clk)
	);			
	
    assign res_o = (m4<<32) + ((m2+m3) << 16) + m1;
	
endmodule


(* use_dsp = "yes" *) module multiplier(

    input wire clk,
    input wire [15:0] a,
    input wire [15:0] b,
    output reg [31:0] res
    
);

    always @(posedge clk) begin
        res <= a*b;
    end

endmodule

