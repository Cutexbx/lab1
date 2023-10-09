`timescale 1ns / 1ps

module FIR_tb(
y
    );

reg clk,rst;
reg[7:0] a,b,c;
reg[7:0] x;
output[7:0] y;


FIR f0(
clk,
rst,
a,b,c,
x,
y
);

initial begin
clk=0;
rst=0;
a=8;//0.5
b=-24;//-1.5
c=32;//2.0
x=0;
#4 rst=1;
end

always #1 begin
    clk<=~clk;
end

always@(posedge clk)begin
    if(rst)begin
        if(x<10*16)begin
            x<=x+16;
        end
    end
end

endmodule
