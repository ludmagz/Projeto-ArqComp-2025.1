`timescale 1ns / 1ps

module Controller (

    // Input
    input logic [6:0] Opcode,
    // 7-bit opcode field from the instruction

    // Outputs
    output logic ALUSrc,
    // 0: The second ALU operand comes from the second register file output (Read data 2); 
    // 1: The second ALU operand is the sign-extended, lower 16 bits of the instruction.
    output logic MemtoReg,
    // 0: The value fed to the register Write data input comes from the ALU.
    // 1: The value fed to the register Write data input comes from the data memory.
    output logic RegWrite, //The register on the Write register input is written with the value on the Write data input 
    output logic MemRead,  //Data memory contents designated by the address input are put on the Read data output
    output logic MemWrite, //Data memory contents designated by the address input are replaced by the value on the Write data input.
    output logic [1:0] ALUOp,  //00: LW/SW; 01:Branch; 10: Rtype
    output logic Branch,  // 0: branch is not taken; 1: branch is taken
    output logic JalPrima,  // JAL boolean
    output logic Halt,
    output logic JalrSel,
    output logic RWSel
);


  // INSTRUÇÕES =========================================
  logic [6:0] R_TYPE, I_TYPE, LW, SW, BR, HALT, JAL, JALR;
  assign R_TYPE = 7'b0110011;  // ADD | AND
  assign I_TYPE = 7'b0010011;  // ADDI | SUBI
  assign LW = 7'b0000011;      // LW
  assign SW = 7'b0100011;      // SW
  assign BR = 7'b1100011;      // BEQ | BNE | BLT | BGE
  assign HALT = 7'b1111111;    // HALT
  assign JAL = 7'b1101111;     // JAL
  assign JALR = 7'b1100111;    // JALR
// ======================================================



  assign ALUSrc = (Opcode == LW || Opcode == SW || Opcode == I_TYPE || Opcode == JALR);
  assign MemtoReg = (Opcode == LW);
  assign RegWrite = (Opcode == R_TYPE || Opcode == LW || Opcode == I_TYPE || Opcode == JALR);
  assign MemRead = (Opcode == LW);
  assign MemWrite = (Opcode == SW);

  assign ALUOp[0] = (Opcode == BR);
  assign ALUOp[1] = ((Opcode == R_TYPE || Opcode == I_TYPE));
  
  assign Branch = (Opcode == BR);
  assign Halt = (Opcode == HALT);
  assign JalPrima = (Opcode == JAL);
  assign JalrSel = (Opcode == JALR);
  assign RWSel = ((Opcode == JALR) || (Opcode == JAL));
  

endmodule
