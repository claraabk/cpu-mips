# Projeto CPU

> Projeto realizado para a cadeira de Infraestrutura de Hardware,que visa a construção de um processador em Verilog com uso de instruções MIPS.
> 
## Diagrama de blocos
![Diagrama de Blocos drawio-2-2 drawio](https://user-images.githubusercontent.com/93380426/190015705-4438d58f-9dc3-4689-a719-ba068f3ea56c.png)
Link: https://drive.google.com/file/d/1N809XXxXkt4eS5ujSzMqBHeMXthd2r5K/view

### Alunas
- Beatriz Ferre  |  @biaferre
- Luiza Diniz  |  @dinizluiza
- Clara Kenderessy  |  @claraabk
- Matheus Silva | @silvama
- Ernesto Gonçalves


### Intruções implementadas pelo grupo:

### Instruções do tipo R

- [x] add rd, rs, rt
- [x] and rd, rs, rt
- [x] sub rd, rs, rt
- [x] sll rd, rt, shamt
- [x] sra rd, rt, shamt
- [x] srl rd, rt, shamt 
- [x] sllv rd, rs, rt
- [x] srav rd, rs, rt
- [x] slt rd, rs, rt
- [x] jr rs
- [x] break 
- [x] Rte 
- [x] mfhi rd
- [x] mflo rd

### Instruções do tipo I

- [x] addi rt, rs, imediato
- [x] addiu rt, rs, imediato
- [x] beq rs,rt, offset
- [x] bne rs, rt, offset 
- [x] ble rs, rt, offset 
- [x] bgt rs, rtx, offset 
- [x] lb rt, offset(rs) 
- [x] lh rt, offset(rs)
- [x] lw rt, offset(rs)
- [x] lui rt, imediato
- [x] sb rt, offset(rs)
- [x] sh rt, offset(rs)
- [x] sw rt, offset(rs)
- [x] slti rt, rs, imediato

### Instruções do tipo J

- [x] j
- [x] jal
- [x] jr 
