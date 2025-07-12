import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  // Configurar validaciones globales
  app.useGlobalPipes(new ValidationPipe({
    whitelist: true,
    forbidNonWhitelisted: true,
    transform: true,
  }));

  // Configurar CORS para el frontend
  app.enableCors({
    origin: [
      'http://localhost:3000', 
      'http://localhost:3001',
      'http://10.0.2.2:3000',      // Emulador Android
      'http://127.0.0.1:3000',
      'http://192.168.1.4:3000',   // Dispositivo físico en red local
      /^https:\/\/.*\.render\.com$/, // Cualquier dominio de Render
      '*', // Permitir todos los orígenes para la app móvil
    ],
    credentials: true,
  });

  // Configurar prefijo global para las rutas de la API
  app.setGlobalPrefix('api');

  // Configurar Swagger
  const config = new DocumentBuilder()
    .setTitle('Gestión de Pedidos API')
    .setDescription('API RESTful para sistema de gestión de pedidos con autenticación JWT, roles de usuario y funcionalidades completas de CRUD')
    .setVersion('1.0.0')
    .addBearerAuth(
      {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT',
        name: 'JWT',
        description: 'Enter JWT token',
        in: 'header',
      },
      'JWT-auth', // This name here is important for matching up with @ApiBearerAuth() in your controller!
    )
    .addTag('Authentication', 'Endpoints para autenticación de usuarios')
    .addTag('Users', 'Gestión de usuarios del sistema')
    .addTag('Products', 'Gestión de productos del catálogo')
    .addTag('Categories', 'Gestión de categorías de productos')
    .addTag('Orders', 'Gestión de pedidos y órdenes')
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, document, {
    customSiteTitle: 'Gestión de Pedidos API',
    customfavIcon: 'https://avatars.githubusercontent.com/u/20165699?s=200&v=4',
    customJs: [
      'https://cdnjs.cloudflare.com/ajax/libs/swagger-ui/4.15.5/swagger-ui-bundle.min.js',
      'https://cdnjs.cloudflare.com/ajax/libs/swagger-ui/4.15.5/swagger-ui-standalone-preset.min.js',
    ],
    customCssUrl: [
      'https://cdnjs.cloudflare.com/ajax/libs/swagger-ui/4.15.5/swagger-ui.min.css',
    ],
  });

  const configService = app.get(ConfigService);
  const port = configService.get<number>('PORT') || 3000;
  
  await app.listen(port, '0.0.0.0');
  console.log(`🚀 Servidor ejecutándose en http://0.0.0.0:${port}/api`);
  console.log(`📚 Documentación Swagger disponible en http://0.0.0.0:${port}/api/docs`);
}
bootstrap();
