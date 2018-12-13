module HighPassFilter(
input clk,
input rst,
input AUD_BCLK,
input AUD_DACLRCK,
input AUD_ADCLRCK,
input [31:0]audioIn,

output reg [31:0]audioOut
);

reg [31:0]lastAudioIn;

wire signed [31:0]leftAudio = { {16{audioIn[31]}}, audioIn[31:16]};
reg signed [256:0]delayedLeft;
reg signed [31:0]filtLeft;

wire signed [31:0]rightAudio = { {16{audioIn[15]}}, audioIn[15:0]};
reg signed [256:0]delayedRight;
reg signed [31:0]filtRight;

parameter n0 = 32'd17706,
			 n1 = 32'd43962,
			 n2 = 32'd39260,
			 n3 = 32'd04301,
			 n4 = 32'd32463,
			 
			 den = 32'd10000;
			 
assign		 b0 = n0/den;
assign		 b1 = n1/den;
assign		 b2 = n2/den;
assign		 b3 = n3/den;
assign		 b4 = n4/den;

always @(*)
begin
	audioOut[31:16] = filtLeft[15:0];
	audioOut[15:0] =  filtRight[15:0];
end


always @(posedge AUD_BCLK)
begin
	if (AUD_DACLRCK == 1)
		begin
			delayedLeft[255:224] <= delayedLeft[223:192]; // x(n-7)
			delayedRight[255:224] <= delayedRight[223:192];
			
			delayedLeft[223:192] <= delayedLeft[191:160]; // x(n-6)
			delayedRight[223:192] <= delayedRight[191:160];
			
			delayedLeft[191:160] <= delayedLeft[159:128]; // x(n-5)
			delayedRight[191:160] <= delayedRight[159:128];
			
			delayedLeft[159:128] <= delayedLeft[127:96]; // x(n-4)
			delayedRight[159:128] <= delayedRight[127:96];
			
			delayedLeft[127:96] <= delayedLeft[95:64]; // x(n-3)
			delayedRight[127:96] <= delayedRight[95:64];
			
			delayedLeft[95:64] <= delayedLeft[63:32]; // x(n-2)
			delayedRight[95:64] <= delayedRight[63:32];
			
			delayedLeft[63:32] <= delayedLeft[31:0]; // x(n-1)
			delayedRight[63:32] <= delayedRight[31:0];
			
			delayedLeft[31:0] <= leftAudio; // x(n)
			delayedRight[31:0] <= rightAudio;
		end
end


always @(posedge AUD_BCLK)
begin
	if (AUD_DACLRCK == 1)
		begin
			filtLeft <= (b1*$signed(delayedLeft[31:0]) - b0*$signed(leftAudio) - b2*$signed(delayedLeft[63:32]) - b3*$signed(delayedLeft[95:64]) + b4*$signed(delayedLeft[127:96]) - b3*$signed(delayedLeft[159:128]) - b2*$signed(delayedLeft[191:160]) + b1*$signed(delayedLeft[223:192]) - b0*$signed(delayedLeft[255:224]));			
			filtRight <= (b1*$signed(delayedRight[31:0]) - b0*$signed(rightAudio) - b2*$signed(delayedRight[63:32]) - b3*$signed(delayedRight[95:64]) + b4*$signed(delayedRight[127:96]) - b3*$signed(delayedRight[159:128]) - b2*$signed(delayedRight[191:160]) + b1*$signed(delayedRight[223:192]) - b0*$signed(delayedRight[255:224]));
		end
end

endmodule