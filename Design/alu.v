//`define MUL 1'b1

module ALU #(parameter w = 8) (
    clk, rst, CE, IN_valid, MODE, CMD, OPA, OPB, Cin,
    ERR, RES, OF, COUT, G, L, E);

    input clk;
    input rst;
    input CE;
    input [1:0] IN_valid;
    input MODE;
    input [3:0] CMD;
    input [w-1:0] OPA;
    input [w-1:0] OPB;
    input Cin;
    output reg ERR;
    output reg OF;
    output reg COUT;
    output reg G;
    output reg L;
    output reg E;
    
`ifdef MUL
    output reg [2*w:0] RES;
`else 
    output reg [w:0] RES;
`endif    
    
reg [1:0] IN_valid_t;
reg [3:0] CMD_t;
reg MODE_t, Cin_t;
reg [w-1:0] OPA_t, OPB_t;
reg ERR_t, OF_t, COUT_t, G_t, L_t, E_t;
reg [2*w:0] RES_t, RES_m;


reg signed [w-1:0] sOPA = {w-1{1'b0}} , sOPB= {w-1{1'b0}};
reg signed [2*w:0] sRES = {2*w{1'b0}};

//parameter SHIFT_w = $clog2(w);
reg [$clog2(w)-1:0] shift_amount;

always @(posedge clk or posedge rst) begin  
    if(rst) begin
        OPA_t <= 0;
        OPB_t <= 0;
        Cin_t <= 0;
        IN_valid_t <= 0;
        MODE_t <= 0;
        CMD_t <= 0; end
        
     else if(CE) begin
        OPA_t <= OPA;
        OPB_t <= OPB;
        Cin_t <= Cin;
        IN_valid_t <= IN_valid;
        MODE_t <= MODE;
        CMD_t <= CMD; end   
end

always @(*) begin
    ERR_t = 0;    
    OF_t = 0;
    COUT_t = 0;
    G_t = 0;
    L_t = 0;
    E_t = 0;
    RES_t = 0;
    
    
    if(MODE_t) begin
        
        case(CMD_t)
            4'b0000: begin 
                        if(IN_valid_t == 2'b11) begin
                            RES_t = OPA_t + OPB_t;
                            COUT_t = RES_t[w]; end
                        else ERR_t = 1; end
            4'b0001: begin 
                        if(IN_valid_t == 2'b11) begin
                            RES_t = OPA_t - OPB_t;
                            OF_t = (OPA_t < OPB_t) ? 1 : 0; end
                        else ERR_t = 1; end
            4'b0010: begin 
                        if(IN_valid_t == 2'b11) begin
                            RES_t = OPA_t + OPB_t + Cin_t;
                            COUT_t = RES_t[w]; end
                        else ERR_t = 1; end
            4'b0011: begin 
                        if(IN_valid_t == 2'b11) begin
                            RES_t = OPA_t - OPB_t - Cin_t;
                            OF_t = (OPA_t < (OPB_t + Cin_t)); end
                        else ERR_t = 1; end
            4'b0100: begin 
                        if(IN_valid_t[0] == 1'b1) begin
                            RES_t = OPA_t + 1'b1;
                            COUT_t = RES_t[w]; end
                        else ERR_t = 1; end
            4'b0101: begin 
                        if(IN_valid_t[0] == 1'b1) begin
                            RES_t = OPA_t - 1'b1;
                            OF_t = RES_t[w]; end
                        else ERR_t = 1; end
            4'b0110: begin 
                        if(IN_valid_t[1] == 1'b1) begin
                            RES_t = OPB_t + 1'b1;
                            COUT_t = RES_t[w]; end
                        else ERR_t = 1; end
            4'b0111: begin 
                        if(IN_valid_t[1] == 1'b1) begin
                            RES_t = OPB_t - 1'b1;
                            OF_t = RES_t[w]; end
                        else ERR_t = 1; end
            4'b1000: begin 
                        if(IN_valid_t == 2'b11) begin
                            E_t = (OPA_t == OPB_t) ? 1 : 0;
                            L_t = (OPA_t < OPB_t) ? 1 : 0;
                            G_t = (OPA_t > OPB_t) ? 1 : 0; end
                        else ERR_t = 1; end
            4'b1001: begin 
                        if(IN_valid_t == 2'b11) begin
                            RES_t = (OPA_t + 1) * (OPB_t + 1); end
                        else ERR_t = 1; end
            4'b1010: begin 
                        if(IN_valid_t == 2'b11) begin
                            RES_t = (OPA_t << 1) * OPB_t; end
                        else ERR_t = 1; end
            4'b1011: begin
                        if(IN_valid_t == 2'b11) begin
                            sOPA = $signed(OPA_t);
                            sOPB = $signed(OPB_t);
                            sRES = sOPA + sOPB;
                            RES_t = sRES;
                            OF_t = ((sOPA[w-1] == sOPB[w-1]) && (sRES[w-1] != sOPA[w-1]));
                            E_t = (sOPA == sOPB) ? 1 : 0;
                            L_t = (sOPA < sOPB) ? 1 : 0;
                            G_t = (sOPA > sOPB) ? 1 : 0; end
                        else ERR_t = 1; end
            4'b1100: begin
                        if(IN_valid_t == 2'b11) begin
                            sOPA = $signed(OPA_t);
                            sOPB = $signed(OPB_t);
                            sRES = sOPA - sOPB;
                            RES_t = sRES;
                            OF_t = ((sOPA[w-1] != sOPB[w-1]) && (sRES[w-1] != sOPA[w-1]));
                            E_t = (sOPA == sOPB) ? 1 : 0;
                            L_t = (sOPA < sOPB) ? 1 : 0;
                            G_t = (sOPA > sOPB) ? 1 : 0; end
                        else ERR_t = 1; end
            default: begin
                        RES_t = 0;
                        COUT_t = 1'b0;
                        OF_t = 1'b0;
                        G_t = 1'b0;
                        E_t = 1'b0;
                        L_t = 1'b0;
                        ERR_t = 1'b1; end
             endcase
             end
             
    else begin 
        case(CMD_t)
          4'b0000: begin
                      if(IN_valid_t == 2'b11) begin
                          RES_t = OPA_t & OPB_t; end
                      else ERR_t = 1; end
          4'b0001: begin
                      if(IN_valid_t == 2'b11) begin
                          RES_t = ~(OPA_t & OPB_t);
                          RES_t[2*w-1 : 8] = 0; end
                      else ERR_t = 1; end
          4'b0010: begin
                      if(IN_valid_t == 2'b11) begin
                          RES_t = OPA_t | OPB_t; end
                      else ERR_t = 1; end
          4'b0011: begin
                      if(IN_valid_t == 2'b11) begin
                          RES_t = ~(OPA_t | OPB_t);
                          RES_t[2*w-1 : 8] = 0; end
                      else ERR_t = 1; end
          4'b0100: begin
                      if(IN_valid_t == 2'b11) begin
                          RES_t = OPA_t ^ OPB_t; end
                      else ERR_t = 1; end
          4'b0101: begin
                      if(IN_valid_t == 2'b11) begin
                          RES_t = ~(OPA_t ^ OPB_t);
                          RES_t[2*w-1 : 8] = 0; end
                      else ERR_t = 1; end
          4'b0110: begin
                      if(IN_valid_t[0] == 1'b1) begin
                          RES_t = ~OPA_t;
                          RES_t[2*w-1 : 8] = 0; end
                      else ERR_t = 1; end
          4'b0111: begin
                      if(IN_valid_t[1] == 1'b1) begin
                          RES_t = ~OPB_t;
                          RES_t[2*w-1 : 8] = 0; end
                      else ERR_t = 1; end
          4'b1000: begin
                      if(IN_valid_t[0] == 1'b1) begin
                          RES_t = OPA_t >> 1; end
                      else ERR_t = 1; end
          4'b1001: begin
                      if(IN_valid_t[0] == 1'b1) begin
                          RES_t = OPA_t << 1; end
                      else ERR_t = 1; end
          4'b1010: begin
                      if(IN_valid_t[1] == 1'b1) begin
                          RES_t = OPB_t >> 1; end
                      else ERR_t = 1; end
          4'b1011: begin
                      if(IN_valid_t[1] == 1'b1) begin
                          RES_t = OPB_t << 1; end
                      else ERR_t = 1; end
          4'b1100: begin 
                      if(IN_valid_t == 2'b11) begin
                          if( |(OPB_t[(w-1) : ($clog2(w)+1)]))
                               ERR_t = 1;
                          else begin
                               shift_amount = OPB_t[$clog2(w)-1:0];
                               RES_t = {1'b0, ((OPA_t << shift_amount) | OPA_t >> (w - shift_amount))}; end end
                      else  ERR_t = 1; end
          4'b1101: begin 
                      if(IN_valid_t == 2'b11) begin
                          if( |(OPB_t[(w-1) : ($clog2(w)+1)]))
                               ERR_t = 1;
                          else begin
                               shift_amount = OPB_t[$clog2(w)-1:0];
                               RES_t = {1'b0, ((OPA_t >> shift_amount) | OPA_t << (w - shift_amount))}; end end
                      else  ERR_t = 1; end
          default: begin
                        RES_t = 0;
                        ERR_t = 1'b1; end
             endcase
             end
end
          
always @(posedge clk or posedge rst) begin
    if (rst) begin
        RES  <= 0;
        COUT <= 0;
        OF   <= 0;
        G    <= 0;
        L    <= 0;
        E    <= 0;
        ERR  <= 0;
        RES_m <= 0;
    end 
    else if (CE) begin
        if ((CMD_t == 4'b1001 || CMD_t == 4'b1010) && MODE_t == 1) begin
            RES_m <= RES_t;
            RES <= RES_m;
        end
        else
            RES <= RES_t;
            COUT <= COUT_t;
            OF   <= OF_t;
            G    <= G_t;
            L    <= L_t;
            E    <= E_t;
            ERR  <= ERR_t;
  end
end
                   
          
            
            
            
    
endmodule
