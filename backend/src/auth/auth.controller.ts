import { Controller, Post, Body, Get, Param } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBody } from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { RegisterDto, LoginDto } from './dto/auth.dto';

@ApiTags('Authentication')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('register')
  @ApiOperation({ summary: 'Registrar nuevo usuario', description: 'Crear una nueva cuenta de usuario en el sistema' })
  @ApiBody({ type: RegisterDto })
  @ApiResponse({ status: 201, description: 'Usuario registrado exitosamente' })
  @ApiResponse({ status: 400, description: 'Datos de registro inválidos' })
  @ApiResponse({ status: 409, description: 'El email ya está registrado' })
  register(@Body() registerDto: RegisterDto) {
    return this.authService.register(registerDto);
  }

  @Post('login')
  @ApiOperation({ summary: 'Iniciar sesión', description: 'Autenticar usuario y obtener token JWT' })
  @ApiBody({ type: LoginDto })
  @ApiResponse({ status: 200, description: 'Login exitoso, token JWT retornado' })
  @ApiResponse({ status: 401, description: 'Credenciales inválidas' })
  login(@Body() loginDto: LoginDto) {
    return this.authService.login(loginDto);
  }

  @Get('test-user/:email')
  @ApiOperation({ summary: 'Verificar usuario de prueba', description: 'Endpoint para verificar datos de usuarios de prueba' })
  @ApiResponse({ status: 200, description: 'Información del usuario obtenida' })
  async testUser(@Param('email') email: string) {
    try {
      const user = await this.authService.testUserCredentials(email);
      return {
        status: 'success',
        userExists: !!user,
        email: user?.email,
        role: user?.role,
        isActive: user?.isActive,
        timestamp: new Date().toISOString(),
      };
    } catch (error) {
      return {
        status: 'error',
        message: error.message,
        timestamp: new Date().toISOString(),
      };
    }
  }

  @Post('debug-login')
  async debugLogin(@Body() loginDto: any) {
    try {
      console.log('Debug login attempt:', loginDto);

      // Verificar si el usuario existe
      const user = await this.authService.testUserCredentials(loginDto.email);
      if (!user) {
        return {
          status: 'error',
          step: 'user_not_found',
          email: loginDto.email,
          message: 'Usuario no encontrado',
        };
      }

      // Verificar password
      const bcrypt = require('bcryptjs');
      const validPassword = await bcrypt.compare(loginDto.password, user.password);
      if (!validPassword) {
        return {
          status: 'error',
          step: 'invalid_password',
          message: 'Contraseña incorrecta',
        };
      }

      return {
        status: 'success',
        step: 'credentials_valid',
        user: {
          id: user.id,
          email: user.email,
          role: user.role,
          isActive: user.isActive,
        },
      };
    } catch (error) {
      return {
        status: 'error',
        step: 'exception',
        message: error.message,
        stack: error.stack,
      };
    }
  }
}
