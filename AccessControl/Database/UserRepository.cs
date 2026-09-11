using AccessControl.Core;
using AccessControl.Data.Records;
using Dapper;
using Npgsql;

namespace AccessControl.Database;


public class UserRepository
{
    private readonly DbConnectionFactory _factory;

    public UserRepository(DbConnectionFactory factory)
    {
        _factory = factory;
    }

    public async Task SaveUsersAsync(List<UserRecord> users)
    {
        using var conn = _factory.Create();
        await conn.OpenAsync();
        var schema = _factory.Schema;

        foreach (var user in users)
        {
            var sql = $@"
                INSERT INTO {schema}.users (id, username)
                VALUES (@Id, @Username)
                ON CONFLICT (id) DO UPDATE SET username = @Username;
            ";

            await conn.ExecuteAsync(sql, user);
        }
    }
}
