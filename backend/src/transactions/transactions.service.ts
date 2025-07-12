import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateTransactionOrderDto } from './dto/create-transaction-order.dto';

@Injectable()
export class TransactionService {
  constructor(private prisma: PrismaService) {}

  // Ejemplo de transacción: Crear pedido y actualizar stock
  async createOrderWithTransaction(createOrderDto: CreateTransactionOrderDto) {
    return await this.prisma.$transaction(async (prisma) => {
      // 1. Verificar stock disponible
      const product = await prisma.product.findUnique({
        where: { id: createOrderDto.productId }
      });

      if (!product) {
        throw new Error('Producto no encontrado');
      }

      if (product.stock < createOrderDto.quantity) {
        throw new Error('Stock insuficiente');
      }

      // 2. Crear el pedido
      const order = await prisma.order.create({
        data: {
          total: createOrderDto.quantity * product.price,
          userId: createOrderDto.userId,
          status: 'PENDING'
        }
      });

      // 3. Actualizar el stock del producto
      const updatedProduct = await prisma.product.update({
        where: { id: product.id },
        data: {
          stock: product.stock - createOrderDto.quantity
        }
      });

      // Si llegamos aquí, todo fue exitoso
      return {
        order,
        updatedProduct,
        message: 'Pedido creado exitosamente con transacción',
        originalStock: product.stock,
        newStock: updatedProduct.stock,
        quantityOrdered: createOrderDto.quantity
      };
    });
  }

  // Ejemplo de transacción que falla intencionalmente
  async createOrderWithFailure(createOrderDto: CreateTransactionOrderDto) {
    try {
      return await this.prisma.$transaction(async (prisma) => {
        // 1. Crear el pedido
        const order = await prisma.order.create({
          data: {
            total: 100,
            userId: createOrderDto.userId,
            status: 'PENDING'
          }
        });

        // 2. Simular un error - esto hará que TODO se revierta
        throw new Error('Error simulado - la transacción se revierte');

        // Este código nunca se ejecutará
        return { order };
      });
    } catch (error) {
      return {
        error: error.message,
        message: 'La transacción falló y se revirtió - no se creó nada en la base de datos'
      };
    }
  }

  // Transacción para transferir stock entre productos
  async transferStock(fromProductId: string, toProductId: string, quantity: number) {
    return await this.prisma.$transaction(async (prisma) => {
      // 1. Verificar producto origen
      const fromProduct = await prisma.product.findUnique({
        where: { id: fromProductId }
      });

      if (!fromProduct || fromProduct.stock < quantity) {
        throw new Error('Stock insuficiente en el producto origen');
      }

      // 2. Verificar producto destino
      const toProduct = await prisma.product.findUnique({
        where: { id: toProductId }
      });

      if (!toProduct) {
        throw new Error('Producto destino no encontrado');
      }

      // 3. Reducir stock del producto origen
      const updatedFromProduct = await prisma.product.update({
        where: { id: fromProductId },
        data: {
          stock: fromProduct.stock - quantity
        }
      });

      // 4. Aumentar stock del producto destino
      const updatedToProduct = await prisma.product.update({
        where: { id: toProductId },
        data: {
          stock: toProduct.stock + quantity
        }
      });

      return {
        fromProduct: updatedFromProduct,
        toProduct: updatedToProduct,
        transferredQuantity: quantity,
        message: 'Transferencia de stock completada exitosamente'
      };
    });
  }

  // Obtener estadísticas de transacciones
  async getTransactionStats() {
    return await this.prisma.$transaction(async (prisma) => {
      const totalOrders = await prisma.order.count();
      const totalProducts = await prisma.product.count();
      const totalUsers = await prisma.user.count();
      const totalRevenue = await prisma.order.aggregate({
        _sum: {
          total: true
        }
      });

      return {
        totalOrders,
        totalProducts,
        totalUsers,
        totalRevenue: totalRevenue._sum.total || 0,
        timestamp: new Date()
      };
    });
  }
}
