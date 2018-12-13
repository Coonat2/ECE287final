module COMB(
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
			filtLeft <= ($signed(leftAudio) - $signed(delayedLeft[255:224]));			
			filtRight <= ($signed(rightAudio) - $signed(delayedRight[255:224]));
		end
end

endmodule