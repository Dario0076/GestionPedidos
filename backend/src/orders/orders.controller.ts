import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Request, Query } from '@nestjs/common';
import { OrdersService } from './orders.service';
import { CreateOrderDto, UpdateOrderStatusDto } from './dto/order.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('orders')
@UseGuards(JwtAuthGuard)
export class OrdersController {
  constructor(private readonly ordersService: OrdersService) {}

  @Post()
  create(@Request() req, @Body() createOrderDto: CreateOrderDto) {
    console.log('🛒 Orders Controller - Received create order request');
    console.log('📋 User ID:', req.user.userId);
    console.log('📦 Order DTO:', JSON.stringify(createOrderDto, null, 2));
    console.log('📊 Order Items Count:', createOrderDto.orderItems?.length || 'undefined');

    return this.ordersService.create(req.user.userId, createOrderDto)
      .then((result) => {
        console.log('✅ Respuesta enviada al frontend:', JSON.stringify(result, null, 2));
        return result;
      })
      .catch((error) => {
        console.error('❌ Error al crear pedido:', error);
        throw error;
      });
  }

  @Get()
  findAll(@Request() req, @Query('all') all?: string) {
    // Si es admin y se solicita ver todas las órdenes
    if (req.user.role === 'ADMIN' && all === 'true') {
      return this.ordersService.findAll();
    }
    // Solo órdenes del usuario actual
    return this.ordersService.findAll(req.user.userId);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.ordersService.findOne(id);
  }

  @Patch(':id/status')
  updateStatus(@Param('id') id: string, @Body() updateOrderStatusDto: UpdateOrderStatusDto) {
    console.log('🔄 Actualizar estado pedido - ID recibido:', id);
    return this.ordersService.findOne(id)
      .then(order => {
        console.log('🔍 Resultado búsqueda pedido:', order ? JSON.stringify(order, null, 2) : 'Pedido no encontrado');
        return this.ordersService.updateStatus(id, updateOrderStatusDto);
      })
      .catch(error => {
        console.error('❌ Error al buscar pedido para actualizar estado:', error);
        throw error;
      });
  }

  @Patch(':id/cancel')
  cancel(@Request() req, @Param('id') id: string) {
    const userId = req.user.role === 'ADMIN' ? undefined : req.user.userId;
    return this.ordersService.cancel(id, userId);
  }
}
