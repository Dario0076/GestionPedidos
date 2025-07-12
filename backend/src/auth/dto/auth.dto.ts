import { IsEmail, IsNotEmpty, IsString, MinLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class RegisterDto {
  @ApiProperty({ 
    example: 'usuario@ejemplo.com', 
    description: 'Email del usuario (debe ser único)' 
  })
  @IsEmail()
  @IsNotEmpty()
  email: string;

  @ApiProperty({ 
    example: 'miPassword123', 
    description: 'Contraseña del usuario (mínimo 6 caracteres)',
    minLength: 6 
  })
  @IsString()
  @IsNotEmpty()
  @MinLength(6)
  password: string;

  @ApiProperty({ 
    example: 'Juan Pérez', 
    description: 'Nombre completo del usuario' 
  })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiProperty({ 
    example: '+593999123456', 
    description: 'Número de teléfono (opcional)',
    required: false 
  })
  @IsString()
  phone?: string;

  @ApiProperty({ 
    example: 'Av. Amazonas 123, Quito', 
    description: 'Dirección del usuario (opcional)',
    required: false 
  })
  @IsString()
  address?: string;
}

export class LoginDto {
  @ApiProperty({ 
    example: 'admin@test.com', 
    description: 'Email del usuario registrado' 
  })
  @IsEmail()
  @IsNotEmpty()
  email: string;

  @ApiProperty({ 
    example: 'admin123', 
    description: 'Contraseña del usuario' 
  })
  @IsString()
  @IsNotEmpty()
  password: string;
}
