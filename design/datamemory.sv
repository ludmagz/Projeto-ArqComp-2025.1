`timescale 1ns / 1ps

module datamemory #(
    parameter DM_ADDRESS = 9,
    parameter DATA_W = 32
) (
    input logic clk,
    input logic MemRead,  // comes from control unit
    input logic MemWrite,  // Comes from control unit
    input logic [DM_ADDRESS - 1:0] a,  // Read / Write address - 9 LSB bits of the ALU output
    input logic [DATA_W - 1:0] wd,  // Write Data
    input logic [2:0] Funct3,  // bits 12 to 14 of the instruction
    output logic [DATA_W - 1:0] rd  // Read Data
);

  logic [31:0] raddress;
  logic [31:0] waddress;
  logic [31:0] Datain;
  logic [31:0] Dataout;
  logic [ 3:0] Wr;

  Memoria32Data mem32 (
      .raddress(raddress),
      .waddress(waddress),
      .Clk(~clk),
      .Datain(Datain),
      .Dataout(Dataout),
      .Wr(Wr)
  );

  always_ff @(*) begin
    raddress = {{22{1'b0}}, {a[8:2], {2{1'b0}}}};
    waddress = {{22{1'b0}}, {a[8:2], {2{1'b0}}}};
    Datain = wd;
    Wr = 4'b0000;

    if (MemRead) begin

      case (Funct3) 
        3'b000: // LB
          case (a[1:0])
            2'b00: rd = {{24{Dataout[7]}},  Dataout[7:0]};      // recebe o bloco 0 de Dataout
            2'b01: rd = {{24{Dataout[15]}}, Dataout[15:8]};      // recebe o bloco 1 de Dataout
            2'b10: rd = {{24{Dataout[23]}}, Dataout[23:16]};     // recebe o bloco 2 de Dataout
            2'b11: rd = {{24{Dataout[31]}}, Dataout[31:24]};     // recebe o bloco 3 de Dataout
          endcase
          
        3'b001: // LH
        case (a[1:0])
            2'b00: rd = {{16{Dataout[15]}}, Dataout[15:0]};
            2'b10: rd = {{16{Dataout[31]}}, Dataout[31:16]};
            default: rd = 32'd0;
        endcase

        3'b010:  // LW
          rd = Dataout;    // recebe todes os blocos de Dataout
            
        3'b100:  //LBU
          case (a[1:0])
            2'b00: rd = {{24{1'b0}}, Dataout[7:0]};   // recebe o bloco 0 de Dataout
            2'b01: rd = {{24{1'b0}}, Dataout[15:8]};  // recebe o bloco 1 de Dataout
            2'b10: rd = {{24{1'b0}}, Dataout[23:16]}; // recebe o bloco 2 de Dataout
            2'b11: rd = {{24{1'b0}}, Dataout[31:24]}; // recebe o bloco 3 de Dataout
          endcase
            
        default: rd = Dataout;
      endcase
        
    end if (MemWrite) begin
        
      case (Funct3)
          
        3'b000: begin  //SB
          case (a[1:0])
            2'b00: begin Wr = 4'b0001; Datain[7:0] = wd[7:0]; end
            2'b01: begin Wr = 4'b0010; Datain[15:8] = wd[7:0]; end
            2'b10: begin Wr = 4'b0100; Datain[23:16] = wd[7:0]; end
            2'b11: begin Wr = 4'b1000; Datain[31:24] = wd[7:0]; end
          endcase
        end
          
        3'b001: begin  // SH
          case (a[1:0])
            2'b00: begin
              Wr = 4'b0011;
              Datain[15:0] = wd[15:0];
            end
            2'b10: begin
              Wr = 4'b1100;
              Datain[31:16] = wd[15:0];
            end
            default: begin
              Wr = 4'b0000; // desalinhado, ignora escrita
            end
          endcase
        end

          
        3'b010: begin  //SW
          Wr = 4'b1111;
          Datain = wd;
        end
          
        default: begin
          Wr = 4'b1111;
          Datain = wd;
        end
          
      endcase
    end
  end

endmodule