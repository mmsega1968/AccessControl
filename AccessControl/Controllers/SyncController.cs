using AccessControl.Core.Sync;
using AccessControl.Database;
using Microsoft.AspNetCore.Mvc;

[ApiController]
[Route("api/sync")]
public class SyncController : ControllerBase
{
    private readonly ClientSyncService _sync;
    private readonly DbConnectionFactory _factory;
    private readonly ILogger<SyncController> _logger;

    public SyncController(
        ClientSyncService sync,
        DbConnectionFactory factory,
        ILogger<SyncController> logger)
    {
        _sync = sync;
        _factory = factory;
        _logger = logger;
    }

    // ------------------------------------------------------------
    // 1. Полная синхронизация
    // ------------------------------------------------------------
    [HttpPost("{clientId}/all")]
    public async Task<IActionResult> SyncAll(string clientId)
    {
        await using var db = _factory.CreateNested(_logger);
        await db.BeginTranAsync();

        try
        {
            await _sync.SyncAllAsync(db, clientId);

            await db.CommitAsync();
            return Ok(new { status = "OK", message = "Full sync completed" });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "[SyncAll] Ошибка");
            await db.RollbackAsync();
            throw;
        }
    }

    // ------------------------------------------------------------
    // 2. Синхронизация справочника свойств
    // ------------------------------------------------------------
    [HttpPost("{clientId}/dictionary")]
    public async Task<IActionResult> SyncDictionary(string clientId)
    {
        await using var db = _factory.CreateNested(_logger);
        await db.BeginTranAsync();

        try
        {
            await _sync.SyncUserPropertyDictionaryAsync(db, clientId);

            await db.CommitAsync();
            return Ok(new { status = "OK", message = "Property dictionary synced" });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "[SyncDictionary] Ошибка");
            await db.RollbackAsync();
            throw;
        }
    }

    // ------------------------------------------------------------
    // 3. Список пользователей
    // ------------------------------------------------------------
    [HttpPost("{clientId}/users")]
    public async Task<IActionResult> SyncUsers(string clientId)
    {
        await using var db = _factory.CreateNested(_logger);
        await db.BeginTranAsync();

        try
        {
            var users = await _sync.SyncUsersAsync(db, clientId);

            await db.CommitAsync();
            return Ok(new { status = "OK", count = users.Count });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "[SyncUsers] Ошибка");
            await db.RollbackAsync();
            throw;
        }
    }

    // ------------------------------------------------------------
    // 4. Свойства конкретного пользователя (username)
    // ------------------------------------------------------------
    [HttpPost("{clientId}/users/{username}/properties")]
    public async Task<IActionResult> SyncUserProperties(string clientId, string username)
    {
        await using var db = _factory.CreateNested(_logger);
        await db.BeginTranAsync();

        try
        {
            // Проверка существования пользователя
            var sql = $@"
                SELECT 1
                FROM {db.Factory.Schema}.users
                WHERE client_id = @ClientId AND username = @Username
                LIMIT 1;
            ";

            var exists = await db.QuerySingleOrDefaultAsync<int?>(sql, new
            {
                ClientId = clientId,
                Username = username
            });

            if (exists is null)
            {
                await db.RollbackAsync();
                return NotFound(new
                {
                    status = "ERROR",
                    message = $"User '{username}' not found for client '{clientId}'"
                });
            }

            await _sync.SyncUserPropertiesAsync(db, clientId, username);

            await db.CommitAsync();
            return Ok(new { status = "OK", userId = username });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "[SyncUserProperties] Ошибка");
            await db.RollbackAsync();
            throw;
        }
    }
}
