`timescale 1ns / 1ps

module top_FIR(

    );

wire clk;
wire memctl;

wire[15:0] memaddraxi;
wire[7:0] memdinaxi;
wire memwenaxi;

reg trigger;

//1st port, controlled by arm or fpga
wire[15:0] memaddra;
wire[7:0] memdina;
wire memwena;
wire[7:0] memdouta;

//2nd port, controlled by fpga
reg[15:0] memaddrb;
reg[7:0] memdinb;
reg memwenb;
wire[7:0] memdoutb;

//fpga controlled memory ports
reg[15:0] memaddrfpga;
reg[7:0] memdinfpga;
reg memwenfpga;

assign memaddra=memctl?memaddraxi:memaddrfpga;
assign memdina=memctl?memdinaxi:memdinfpga;
assign memwena=memctl?memwenaxi:memwenfpga;

datatrans_sys_wrapper mw0
       (.axiclk(clk),
        .memaddr(memaddraxi),
        .memctl(memctl),
        .memdin(memdinaxi),
        .memdout(memdouta),
        .memwen(memwenaxi),
        .triggerin(trigger));

blk_mem_gen_0 b0
  (
      clk,
      memwena,
      memaddra,
      memdina,
      memdouta,
      clk,
      memwenb,
      memaddrb,
      memdinb,
      memdoutb
  );

reg[7:0] x;
wire[7:0] y;
reg[7:0] a,b,c;
reg rst;

FIR f0(
clk,
~memctl,
a,b,c,
x,
y
);

reg[7:0] i,j;

reg[7:0] state;

reg[15:0] count;

always@(posedge clk)begin
	if(memctl)begin
	    state<=0;
	    count<=0;
	    a<=0;
	    b<=0;
	    c<=0;
	    trigger<=0;
	    
	    memwenfpga<=0;
	    memaddrfpga<=0;
	    memdinfpga<=0;
	    
	    memwenb<=0;
	    memaddrb<=0;
	    memdinb<=0;
	end 
	else begin
		case(state)
		0:begin
		  if(count>=2)begin
		    case(count)
		    2:begin
		      a<=memdoutb;
		    end
		    3:begin
		      b<=memdoutb;
		    end
		    4:begin
		      c<=memdoutb;
		      state<=state+1;
		    end
		    endcase
		  end
		  count<=count+1;
		  memwenb<=0;
          memaddrb<=memaddrb+1;
		end
		1:begin
		  memwenfpga<=0;
          memaddrfpga<=3;
          memdinfpga<=0;
		  memwenb<=1;
          memaddrb<=2000;
          memdinb<=0;
          count<=0;
          state<=state+1;
		end
		2:begin
		  if(count>=2)begin
		    x<=memdouta;
		  end
		  if(count>=3)begin
		    memdinb<=y;
		  end
		  if(count>=4)begin
		    memaddrb<=memaddrb+1;
		  end
		  memaddrfpga<=memaddrfpga+1;
		  if(count<4)begin
		    count<=count+1;
		  end
		  if(memaddrb>=3005)begin
		      state<=state+1;
		  end
		end
		3:begin
		  memwenfpga<=0;
          memaddrfpga<=0;
          memdinfpga<=0;
          memwenb<=0;
          memaddrb<=0;
          memdinb<=0;
          trigger<=1;
		end
		endcase
	end
end

endmodule
