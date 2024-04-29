module cpop_tb;
    
    reg [31:0] in_s;
    wire [31:0] out_s;
    
    cpop_module cpop(in_s, out_s);

    initial begin
        $dumpfile("cpop.vcd");
        $dumpvars(0,in_s,out_s);
        #0
        in_s = 32'b00101111000000011100011000100010;

        #50 
        in_s = 32'b00101111001100011100011110100011;

        #100
        in_s = 32'b00101000000000000100000000100000;

        #200;
        $finish;
    end
    
endmodule