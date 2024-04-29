module clz_tb;
    
    reg [31:0] in_s;
    wire [5:0] out_s;
    
    clz_encoder clz(in_s, out_s);

    initial begin
        $dumpfile("clz.vcd");
        $dumpvars(0,in_s,out_s);
        #0
        in_s = 32'b0;

        #50 
        in_s = 32'b11111111111111111111111111111111;

        #100
        in_s = 32'b00000000000000000100000000100000;
        
        #150
        in_s = 32'b00001111001100011100011110100011;

        #200;
        in_s = 32'b00101111000000011100011000100010;
        
        #300;
        $finish;
    end
    
endmodule