import { DbService } from '../db.service';
import { User } from './users.type';

export class UsersService {
  constructor(private dbService: DbService) {}

  async findByEmail(email: string): Promise<User | null> {
    const sql = `select *
                 from users
                 where email = ?
                 limit 1`;
    const rs = await this.dbService.execute<User[]>(sql, [email]);
    return rs.length > 0 ? rs[0] : null;
  }
}
