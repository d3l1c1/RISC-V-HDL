module ctz_tb;
    
    reg [31:0] in_s;
    wire [31:0] reversed_input_s;
    wire [5:0] out_s;
    
    clz_encoder ctz(reversed_input_s, out_s);
    
    generate
        genvar i;
        for (i = 0; i < 32; i = i + 1) begin
            assign reversed_input_s[i] = in_s[31 - i];
        end
    endgenerate

    initial begin
        $dumpfile("ctz.vcd");
        $dumpvars(0,in_s,out_s);
        #0
        in_s = 32'b0;

        #50 
        in_s = 32'b11111111111111111111111111111111;

        #100
        in_s = 32'b00000001100000000000000000000000; // 23
        
        #150
        in_s = 32'b00001111001100011100011110110000; //4

        #200;
        in_s = 32'b00101111000000011100011000100010; //1
        
        #300;
        $finish;
    end
    
endmodule