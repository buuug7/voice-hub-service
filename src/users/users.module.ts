import { Module } from '@nestjs/common';
import { UsersService } from './users.service';
import { DbService } from '../db.service';
import { UsersController } from './users.controller';

@Module({
  imports: [],
  providers: [UsersService, DbService],
  controllers: [UsersController],
  exports: [UsersService],
})
export class UsersModule {}
