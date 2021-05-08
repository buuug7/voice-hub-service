import { DbService } from '../db.service';
import { User } from './users.type';
import { ConflictException, Injectable } from '@nestjs/common';
import * as dayjs from 'dayjs';
import { ResultSetHeader } from 'mysql2';
import { randomStringGenerator } from '@nestjs/common/utils/random-string-generator.util';
import { hashSync } from 'bcrypt';

@Injectable()
export class UsersService {
  constructor(private dbService: DbService) {}

  async crete(data: Partial<User>) {
    const exists = await this.findByEmail(data.email);
    if (exists) {
      throw new ConflictException('an email is already exists');
    }

    const sql = `insert into users(id, name, email, password, active, loginFrom, createdAt, updatedAt)
                 values (?, ?, ?, ?, ?, ?, ?, ?)`;

    const dateTime = dayjs().format('YYYY-MM-DD HH:mm:ss');
    await this.dbService.execute<ResultSetHeader>(sql, [
      randomStringGenerator(),
      data.name,
      data.email,
      hashSync(data.password, 3),
      '1',
      JSON.stringify({}),
      dateTime,
      dateTime,
    ]);

    return this.getProfile(data.email);
  }

  async update(id: string, data: { name: string }) {
    const sql = `update users
                 set name = ?
                 where id = ?`;
    await this.dbService.execute<ResultSetHeader>(sql, [data.name, id]);
    const user = await this.findById(id);
    return this.mapDatabaseUserToUserProfile(user);
  }

  async getProfile(email: string) {
    const user = await this.findByEmail(email);
    return this.mapDatabaseUserToUserProfile(user);
  }

  async findById(id: string) {
    const sql = `select *
                 from users
                 where id = ?
                 limit 1`;
    const rs = await this.dbService.execute<User[]>(sql, [id]);

    return rs.length > 0 ? rs[0] : null;
  }

  async findByEmail(email: string): Promise<User | null> {
    const sql = `select *
                 from users
                 where email = ?
                 limit 1`;
    const rs = await this.dbService.execute<User[]>(sql, [email]);
    return rs.length > 0 ? rs[0] : null;
  }

  /**
   * 数据库user数据映射部分字段为用户资料，返回给前端
   * @param user
   */
  mapDatabaseUserToUserProfile(user: User): Partial<User> {
    return {
      id: user.id,
      name: user.name,
      email: user.email,
      active: user.active,
      createdAt: user.createdAt,
    };
  }
}
