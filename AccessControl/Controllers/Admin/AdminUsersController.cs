using AccessControl.Database;
using Microsoft.AspNetCore.Mvc;

namespace AccessControl.Controllers.Admin;

[ApiController]
[Route("api/admin/users")]
public class AdminUsersController : ControllerBase
{
    private readonly DbConnectionFactory _factory;
    private readonly ILogger<AdminUsersController> _logger;

    public AdminUsersController(
        DbConnectionFactory factory,
        ILogger<AdminUsersController> logger)
    {
        _factory = factory;
        _logger = logger;
    }

    /// <summary>
    /// Возвращает список пользователей для указанного клиента
    /// </summary>
    [HttpGet("{clientId}")]
    public async Task<IActionResult> GetUsers(string clientId)
    {
        _logger.LogInformation("[Admin] Получение списка пользователей для клиента '{clientId}'");

        await using var db = _factory.CreateNested(_logger);

        var sql = $@"
            SELECT id, username
            FROM {db.Factory.Schema}.users
            WHERE client_id = @ClientId
            ORDER BY username;
        ";

        var users = await db.QueryAsync<dynamic>(sql, new { ClientId = clientId });

        return Ok(users);
    }
}
