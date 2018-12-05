module CLA_24(x,y,cin,sum);
input cin;
input [23:0] x,y;
output [23:0] sum;

wire [23:0]cout;
CLA_4 B0(x[3:0],y[3:0],cin,sum[3:0],cout[3:0]);
CLA_4 B1(x[7:4],y[7:4],cout[3],sum[7:4],cout[7:4]);
CLA_4 B2(x[11:8],y[11:8],cout[7],sum[11:8],cout[11:8]);
CLA_4 B3(x[15:12],y[15:12],cout[11],sum[15:12],cout[15:12]);
CLA_4 B4(x[19:16],y[19:16],cout[15],sum[19:16],cout[19:16]);
CLA_4 B5(x[23:20],y[23:20],cout[19],sum[23:20],cout[23:20]);
endmodule

module CLA_4(a,b,cin,s,cout);
input cin;
input [3:0] a,b;
output [3:0] s,cout;
wire [3:0] g,p;
assign g[0] = a[0] & b[0];
assign g[1] = a[1] & b[1];
assign g[2] = a[2] & b[2];
assign g[3] = a[3] & b[3];
assign p[0] = a[0] ^ b[0];
assign p[1] = a[1] ^ b[1];
assign p[2] = a[2] ^ b[2];
assign p[3] = a[3] ^ b[3];
assign cout[0] = g[0] | (p[0] & cin);
assign cout[1] = g[1] | (p[1] & g[0]) | (p[1] & p[0] & cin);
assign cout[2] = g[2] | (p[2] & g[1]) | (p[2] & p[1] & g[0]) | (p[2] & p[1] & p[0] & cin);
assign cout[3] = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1]) | (p[3] & p[2] & p[1] & g[0]) | (p[3] & p[2] & p[1] & p[0] & cin);
assign s[0] = p[0] ^ cin;
assign s[1] = p[1] ^ cout[0];
assign s[2] = p[2] ^ cout[1];
assign s[3] = p[3] ^ cout[2];
endmodule



module matrixmul(clock,mem1,mem2,mem3,addr,wm,in);

input [9:0] in;
input clock;
input [1:0]wm;
input [1:0]addr;
reg [23:0] mem [4:0];
output reg [23:0] mem1,mem2,mem3;
reg [23:0] ans;
wire [23:0] s0,s1,s2,s3;
integer i;
integer operate;
reg [9:0] a,b;
reg [9:0] RAM[1:0];
integer k;

initial begin 
	mem1 = 0; mem[0] =0; mem[1] = 0; mem[2] =0; mem[3] = 0; mem[4]=0;ans=0; 
end

always@(posedge clock)begin
	case (wm)
	2'b00:begin
		RAM[addr] = in;
		a = RAM[0];
		b = RAM[1];	
	end
	2'b01: begin
		mem2 = RAM[0];
		//$display($realtime,"ns Read a = %d",mem2);
		
		//$display($realtime,"ns Read b = %d",mem2);		
	end
	2'b11: begin
		mem1 = a+b;
		//$display($realtime,"ns ADD %d",mem1);
	end
	2'b10: begin
		k = 0;
		for( i = 1; i <= 9; i = i + 2 ) begin
			if(i==1) begin
				operate = b[0] - b[1] - b[1]; 
			end   
			else begin 
				operate = b[i-1] + b[i-2] - b[i] - b[i];
			end
			case (operate)
			1: begin
				ans = a;
				ans  = ans<< (i-1);
				mem[(i-1)/2] = ans;
			end
			2: begin 
				ans = a<<1;
				ans = ans << (i-1);
				mem[(i-1)/2] = ans;
			end
			-1: begin
				ans = ~a+1;
				ans = ans << (i-1);
				mem[(i-1)/2] = ans;
			end
			-2: begin
				ans = a<<1;
				ans = ~ans + 1;
				ans = ans << (i-1);
				mem[(i-1)/2] = ans;
			end
			0: begin
				ans = 0;
				mem[(i-1)/2] = ans;
			end
			endcase	
		
		end	
		
	end
endcase
end
	CLA_24 c1(mem[0],mem[1],0,s0);
	CLA_24 c2(mem[2],mem[3],0,s1);
	CLA_24 c3(mem[4],s0,0,s2);
	CLA_24 c4(s2,s1,0,s3);
	always@(posedge clock)begin
		mem3 = s3; 
		k = k + 1;
		
		/*if (a*b != s3 && k == 8)begin
			//$display($realtime," ERROR");
		end		
		else begin
			//$display($realtime," TRUE");
		end*/
	
end
	
endmodule
