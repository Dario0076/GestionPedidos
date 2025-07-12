import { Controller, Post, Body, Get, Param, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiBody } from '@nestjs/swagger';
import { TransactionService } from './transactions.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { CreateTransactionOrderDto } from './dto/create-transaction-order.dto';

@ApiTags('Transactions')
@Controller('transactions')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth('JWT-auth')
export class TransactionsController {
  constructor(private readonly transactionsService: TransactionService) {}

  @Post('create-order')
  @ApiOperation({ 
    summary: 'Crear pedido con transacción',
    description: 'Demuestra transaccionabilidad: crea pedido y actualiza stock de forma atómica'
  })
  @ApiBody({ type: CreateTransactionOrderDto })
  @ApiResponse({ status: 201, description: 'Pedido creado exitosamente con transacción' })
  @ApiResponse({ status: 400, description: 'Error en la transacción (stock insuficiente, etc.)' })
  async createOrderWithTransaction(@Body() createOrderDto: CreateTransactionOrderDto) {
    return this.transactionsService.createOrderWithTransaction(createOrderDto);
  }

  @Post('create-order-with-failure')
  @ApiOperation({ 
    summary: 'Demostrar fallo de transacción',
    description: 'Simula un error para mostrar cómo se revierten las transacciones'
  })
  @ApiBody({ type: CreateTransactionOrderDto })
  @ApiResponse({ status: 201, description: 'Muestra cómo se revierte la transacción en caso de error' })
  async createOrderWithFailure(@Body() createOrderDto: CreateTransactionOrderDto) {
    return this.transactionsService.createOrderWithFailure(createOrderDto);
  }

  @Post('transfer-stock/:fromId/:toId/:quantity')
  @Roles('ADMIN')
  @UseGuards(RolesGuard)
  @ApiOperation({ 
    summary: 'Transferir stock entre productos',
    description: 'Demuestra transacción compleja: transfiere stock de un producto a otro'
  })
  @ApiResponse({ status: 201, description: 'Transferencia completada exitosamente' })
  @ApiResponse({ status: 400, description: 'Error en la transferencia' })
  @ApiResponse({ status: 403, description: 'Acceso denegado - requiere rol ADMIN' })
  async transferStock(
    @Param('fromId') fromId: string,
    @Param('toId') toId: string,
    @Param('quantity') quantity: string
  ) {
    return this.transactionsService.transferStock(fromId, toId, parseInt(quantity));
  }

  @Get('stats')
  @Roles('ADMIN')
  @UseGuards(RolesGuard)
  @ApiOperation({ 
    summary: 'Obtener estadísticas del sistema',
    description: 'Demuestra lectura transaccional para garantizar consistencia de datos'
  })
  @ApiResponse({ status: 200, description: 'Estadísticas obtenidas exitosamente' })
  @ApiResponse({ status: 403, description: 'Acceso denegado - requiere rol ADMIN' })
  async getStats() {
    return this.transactionsService.getTransactionStats();
  }
}
