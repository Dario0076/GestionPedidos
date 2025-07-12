import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsNumber, IsPositive, IsUUID } from 'class-validator';

export class CreateTransactionOrderDto {
  @ApiProperty({ 
    description: 'ID del producto a ordenar',
    example: 'cm3abc123def456ghi789jkl'
  })
  @IsString()
  @IsUUID()
  productId: string;

  @ApiProperty({ 
    description: 'ID del usuario que hace el pedido',
    example: 'cm3xyz789abc012def345ghi'
  })
  @IsString()
  @IsUUID()
  userId: string;

  @ApiProperty({ 
    description: 'Cantidad a ordenar',
    example: 2,
    minimum: 1
  })
  @IsNumber()
  @IsPositive()
  quantity: number;
}
