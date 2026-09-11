using AccessControl.Database;

public class RoleService : IRoleService
{
    private readonly DbConnectionFactory _factory;
    private readonly ILogger<RoleService> _logger;

    public RoleService(DbConnectionFactory factory, ILogger<RoleService> logger)
    {
        _factory = factory;
        _logger = logger;
    }

    // ---------------------------------------------------------
    // GET ROLES
    // ---------------------------------------------------------
    public async Task<IEnumerable<RoleDto>> GetRolesAsync(string clientId)
    {
        using var db = _factory.CreateNested(_logger);

        var sql = $@"
            SELECT client_id, role_code, role_name, is_active
            FROM {_factory.Schema}.access_roles
            WHERE client_id = @ClientId
            ORDER BY role_code;
        ";

        return await db.QueryAsync<RoleDto>(sql, new { ClientId = clientId });
    }

    // ---------------------------------------------------------
    // GET ROLE
    // ---------------------------------------------------------
    public async Task<RoleDto?> GetRoleAsync(string clientId, string roleCode)
    {
        using var db = _factory.CreateNested(_logger);

        var sql = $@"
        SELECT client_id, role_code, role_name, is_active
        FROM {db.Factory.Schema}.access_roles
        WHERE client_id = @ClientId
          AND role_code = @RoleCode;
    ";

        var finalSql = db.Factory.BuildSql(sql, new
        {
            ClientId = clientId,
            RoleCode = roleCode,
        });

        RoleDto r = await db.QuerySingleOrDefaultAsync<RoleDto>(finalSql);
        return r;
    }


    // ---------------------------------------------------------
    // CREATE ROLE
    // ---------------------------------------------------------
    public async Task<RoleDto> CreateRoleAsync(RoleDto dto)
    {
        using var db = _factory.CreateNested(_logger);
        await db.BeginTranAsync();

        try
        {
            var sqlInsert = $@"
                INSERT INTO {_factory.Schema}.access_roles
                    (client_id, role_code, role_name, is_active, created_at)
                VALUES
                    (@ClientId, @RoleCode, @RoleName, @IsActive, now());
            ";

            await db.ExecuteAsync(sqlInsert, dto);

            var sqlHistory = $@"
                INSERT INTO {_factory.Schema}.access_role_history
                    (client_id, role_code, change_type, old_value, new_value, changed_at)
                VALUES
                    (@ClientId, @RoleCode, 'create', NULL, @RoleName, now());
            ";

            await db.ExecuteAsync(sqlHistory, dto);

            await db.CommitAsync();
            return dto;
        }
        catch
        {
            await db.RollbackAsync();
            throw;
        }
    }

    // ---------------------------------------------------------
    // UPDATE ROLE
    // ---------------------------------------------------------
    public async Task<RoleDto?> UpdateRoleAsync(string clientId, string roleCode, RoleDto dto)
    {
        using var db = _factory.CreateNested(_logger);
        await db.BeginTranAsync();

        try
        {
            var sqlOld = $@"
                SELECT role_name
                FROM {_factory.Schema}.access_roles
                WHERE client_id = @client_id AND role_code = @role_code;
            ";

            var oldName = await db.QuerySingleOrDefaultAsync<string>(sqlOld, new
            {
                client_id = clientId,
                role_code = roleCode
            });

            if (oldName == null)
            {
                await db.RollbackAsync();
                return null;
            }

            var sqlUpdate = $@"
                UPDATE {_factory.Schema}.access_roles
                SET role_name = @RoleName,
                    is_active = @IsActive
                WHERE client_id = @ClientId AND role_code = @RoleCode;
            ";

            await db.ExecuteAsync(sqlUpdate, dto);

            var sqlHistory = $@"
                INSERT INTO {_factory.Schema}.access_role_history
                    (client_id, role_code, change_type, old_value, new_value, changed_at)
                VALUES
                    (@ClientId, @RoleCode, 'rename', @OldValue, @NewValue, now());
            ";

            await db.ExecuteAsync(sqlHistory, new
            {
                ClientId = clientId,
                RoleCode = roleCode,
                OldValue = oldName,
                NewValue = dto.role_name
            });

            await db.CommitAsync();
            return dto;
        }
        catch
        {
            await db.RollbackAsync();
            throw;
        }
    }

    // ---------------------------------------------------------
    // RETIRE ROLE
    // ---------------------------------------------------------
    public async Task<bool> RetireRoleAsync(string clientId, string roleCode)
    {
        using var db = _factory.CreateNested(_logger);
        await db.BeginTranAsync();

        try
        {
            var sql = $@"
                UPDATE {_factory.Schema}.access_roles
                SET is_active = false,
                    retired_at = now()
                WHERE client_id = @ClientId AND role_code = @RoleCode;
            ";

            var affected = await db.ExecuteAsync(sql, new
            {
                ClientId = clientId,
                RoleCode = roleCode
            });

            if (affected == 0)
            {
                await db.RollbackAsync();
                return false;
            }

            var sqlHistory = $@"
                INSERT INTO {_factory.Schema}.access_role_history
                    (client_id, role_code, change_type, old_value, new_value, changed_at)
                VALUES
                    (@ClientId, @RoleCode, 'retire', NULL, NULL, now());
            ";

            await db.ExecuteAsync(sqlHistory, new
            {
                ClientId = clientId,
                RoleCode = roleCode
            });

            await db.CommitAsync();
            return true;
        }
        catch
        {
            await db.RollbackAsync();
            throw;
        }
    }
}
