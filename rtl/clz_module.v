module enc
(
   input [1:0] d,
   output reg [1:0] q
);

   always @* begin
      case (d[1:0])
         2'b00    :  q = 2'b10;
         2'b01    :  q = 2'b01;
         default  :  q = 2'b00;
      endcase
   end

endmodule // enc

module clzi #
(
   // external parameter
   parameter   N = 2,
   // internal parameters
   parameter   WI = 2 * N,
   parameter   WO = N + 1
)
(
   input [WI-1:0] d,
   output reg [WO-1:0] q
);

   always @* begin
      if (d[N - 1 + N] == 1'b0) begin
         q[WO-1] = (d[N-1+N] & d[N-1]);
         q[WO-2] = 1'b0;
         q[WO-3:0] = d[(2*N)-2 : N];
      end else begin
         q[WO-1] = d[N-1+N] & d[N-1];
         q[WO-2] = ~d[N-1];
         q[WO-3:0] = d[N-2 : 0];
      end
   end

endmodule // clzi

module clz_encoder #(
    parameter WIDTH_IN = 32, 
    parameter WIDTH_OUT = $clog2(WIDTH_IN)+1
) (
    input [WIDTH_IN-1:0] in,
    output [WIDTH_OUT-1:0] out
);

    genvar i;
    wire [31:0] encoder_o;
    wire [23:0] a;
    wire [15:0] b;
    wire [9:0] c;

    generate
        for (i = 0; i < 16; i = i + 1) begin
            enc e1(
                .d(in[i*2+1:i*2]),
                .q(encoder_o[i*2+1:i*2])
            );
        end

        for (i = 0; i < 8; i = i + 1) begin
            clzi #(.N(2)) m1 (
                .d(encoder_o[i*4+3:i*4]),
                .q(a[i*3+2:i*3])
            );
        end

        for (i = 0; i < 4; i = i + 1) begin
            clzi #(.N(3)) m2 (
                .d(a[i*6+5:i*6]),
                .q(b[i*4+3:i*4])
            );
        end

        for (i = 0; i < 2; i = i + 1) begin
            clzi #(.N(4)) m3 (
                .d(b[i*8+7:i*8]),
                .q(c[i*5+4:i*5])
            );
        end

        clzi #(.N(5)) m4 (
                .d(c[9:0]),
                .q(out)
            );
    endgenerate
    
endmodule

