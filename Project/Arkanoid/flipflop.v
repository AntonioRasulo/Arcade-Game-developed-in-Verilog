module flipflop(clk,rst,i_xdirpal,i_ydirpal,i_xnav,i_ynav,i_xpal,i_ypal,i_bri1,i_bri2,i_bri3, i_bri4,i_bri5,i_bri6,i_bri7, i_bri8,
				i_bri9, i_bri10,o_bri1,o_bri2,o_bri3, o_bri4,o_bri5,o_bri6,o_bri7, o_bri8, o_bri9, o_bri10,
				i_life, o_life, i_brick, o_brick, i_red1, i_red2, i_red3, i_red4, i_blue5, i_blue6, i_blue7, o_red1,o_red2,o_red3,o_red4,
				o_blue5, o_blue6, o_blue7,o_xdirpal,o_ydirpal,o_xnav,o_ynav,o_xpal,o_ypal
);

input clk,rst;
input i_xdirpal, i_ydirpal;
input [9:0] i_xnav,i_ynav,i_xpal,i_ypal;
input i_bri1,i_bri2,i_bri3, i_bri4,i_bri5,i_bri6,i_bri7, i_bri8,i_bri9,i_bri10 ;
 //ingressi flipflop
output reg [9:0] o_xnav,o_ynav,o_xpal,o_ypal;
output reg  o_xdirpal,o_ydirpal;
output reg o_bri1,o_bri2,o_bri3, o_bri4,o_bri5,o_bri6,o_bri7, o_bri8, o_bri9, o_bri10;//uscite flipflop
output reg [1:0] o_life;
output reg [3:0] o_brick;

input [1:0]  i_life;
input [3:0]  i_brick;
input [1:0] i_red1, i_red2, i_red3, i_red4;
input[1:0] i_blue5, i_blue6, i_blue7;
output reg [1:0]  o_red1,o_red2,o_red3,o_red4;
output reg [1:0]   o_blue5, o_blue6, o_blue7;


parameter IX_NAV = 10'd 320;	//coordinata x iniziale del centro della navicella
parameter IY_NAV = 10'd 470;
parameter IX_PAL = 10'd 320;	//coordinata x iniziale del centro della palla
parameter IY_PAL = 10'd 450;
parameter VITE = 2'd 3;
parameter BLOCCHI = 4'd 10;
parameter RED = 2'd 3;
parameter BLUE = 2'd 2;

always@(posedge clk)
	if(rst) begin							// se reset condizioni iniziali
				o_bri1<=1'b1;
				o_bri2<=1'b1;
				o_bri3<=1'b1;
				o_bri4<=1'b1;
				o_bri5<=1'b1;
				o_bri6<=1'b1;
				o_bri7<=1'b1;
				o_bri8<=1'b1;
				o_bri9<=1'b1;
				o_bri10<=1'b1;
				o_xdirpal<=1'b0;
				o_xnav<=IX_NAV;
				o_xpal<=IX_PAL;
				o_ydirpal<=1'b0;
				o_ynav<=IY_NAV;
				o_ypal<=IY_PAL;				
				o_life<=VITE;
				o_brick<=BLOCCHI;
				o_blue5<=BLUE;
				o_blue6<=BLUE;
				o_blue7<=BLUE;
				o_red1<=RED;
				o_red2<=RED;
				o_red3<=RED;
				o_red4<=RED;
			end
	else	begin							// sennò campionamento
				o_bri1<=i_bri1;
				o_bri2<=i_bri2;
				o_bri3<=i_bri3;
				o_bri4<=i_bri4;
				o_bri5<=i_bri5;
				o_bri6<=i_bri6;
				o_bri7<=i_bri7;
				o_bri8<=i_bri8;
				o_bri9<=i_bri9;
				o_bri10<=i_bri10;
				o_xdirpal<=i_xdirpal;
				o_xnav<=i_xnav;
				o_xpal<=i_xpal;
				o_ydirpal<=i_ydirpal;
				o_ynav<=i_ynav;
				o_ypal<=i_ypal;
				o_life<=i_life;
				o_brick<=i_brick;
				o_blue5<=i_blue5;
				o_blue6<=i_blue6;
				o_blue7<=i_blue7;
				o_red1<=i_red1;
				o_red2<=i_red2;
				o_red3<=i_red3;
				o_red4<=i_red4;
			end
endmodule