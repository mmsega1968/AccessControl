using AccessControl.Core.WebSockets.RpcModels;
using System.Text.Json;

namespace AccessControl.Core.Sync;

public class ClientSyncService
{
    private readonly WebSocketRpcService _rpc;
    private readonly ILogger<ClientSyncService> _logger;

    public ClientSyncService(
        WebSocketRpcService rpc,
        ILogger<ClientSyncService> logger)
    {
        _rpc = rpc;
        _logger = logger;
    }

    // ------------------------------------------------------------
    // 1. Синхронизация справочника свойств
    // ------------------------------------------------------------
    public async Task SyncUserPropertyDictionaryAsync(
        NestedTransactionConnection db,
        string clientId)
    {
        _logger.LogInformation("[Sync] Запрос справочника свойств");

        var response = await _rpc.CallAsync<PropertyDictionaryResponse>(
            clientId,
            "SyncUserPropertyDictionary",
            new { }
        );

        _logger.LogInformation(
            "[Sync] Клиент вернул {Count} элементов справочника свойств",
            response.PropertyDictionary?.Count ?? -1);

        await SaveDictionaryAsync(db, clientId, response.PropertyDictionary);

        _logger.LogInformation("[Sync] Справочник свойств сохранён");
    }

    // ------------------------------------------------------------
    // 2. Список пользователей
    // ------------------------------------------------------------
    public async Task<List<UserDto>> SyncUsersAsync(
        NestedTransactionConnection db,
        string clientId)
    {
        _logger.LogInformation("[Sync] Запрос списка пользователей");

        var response = await _rpc.CallAsync<UsersResponse>(
            clientId,
            "SyncUsers",
            new { }
        );

        await SaveUsersAsync(db, clientId, response.Users);

        _logger.LogInformation("[Sync] Список пользователей сохранён");

        return response.Users;
    }

    // ------------------------------------------------------------
    // 3. Свойства конкретного пользователя
    // ------------------------------------------------------------
    public async Task SyncUserPropertiesAsync(
        NestedTransactionConnection db,
        string clientId,
        string username)
    {
        _logger.LogInformation("[Sync] Запрос свойств пользователя {User}", username);

        var response = await _rpc.CallAsync<UserPropertiesResponse>(
            clientId,
            "SyncUserProperties",
            new { userId = username }
        );

        await SaveUserPropertiesAsync(db, clientId, username, response.Properties);

        _logger.LogInformation("[Sync] Свойства пользователя {User} сохранены", username);
    }

    // ------------------------------------------------------------
    // 4. Полная синхронизация
    // ------------------------------------------------------------
    public async Task SyncAllAsync(
    NestedTransactionConnection db,
    string clientId)
    {
        _logger.LogInformation("[SyncAll] Начало полной синхронизации");

        // 1. Синхронизация справочника свойств
        await SyncUserPropertyDictionaryAsync(db, clientId);

        // 2. Синхронизация списка пользователей
        var users = await SyncUsersAsync(db, clientId);

        // 3. Синхронизация свойств каждого пользователя
        foreach (var user in users)
            await SyncUserPropertiesAsync(db, clientId, user.Username);

        _logger.LogInformation("[SyncAll] Полная синхронизация завершена");
    }


    // ------------------------------------------------------------
    // Методы сохранения в БД
    // ------------------------------------------------------------

    private async Task SaveDictionaryAsync(
        NestedTransactionConnection db,
        string clientId,
        List<PropertyDto> dict)
    {
        foreach (var item in dict)
        {
            var sql = $@"
                INSERT INTO {db.Factory.Schema}.user_property_dictionary
                    (id, client_id, property_code, title, type, is_required, default_value, description)
                VALUES
                    (@Id, @ClientId, @PropertyCode, @Title, @Type, @IsRequired, @DefaultValue, @Description)
                ON CONFLICT (client_id, property_code)
                DO UPDATE SET
                    title = EXCLUDED.title,
                    type = EXCLUDED.type,
                    is_required = EXCLUDED.is_required,
                    default_value = EXCLUDED.default_value,
                    description = EXCLUDED.description;
            ";

            var finalSql = db.Factory.BuildSql(sql, new
            {
                Id = string.IsNullOrWhiteSpace(item.Id)
                    ? Guid.NewGuid()
                    : Guid.Parse(item.Id),

                ClientId = clientId,
                PropertyCode = item.PropertyCode,
                Title = item.Title,
                Type = item.Type,
                IsRequired = item.IsRequired,
                DefaultValue = item.DefaultValue,
                Description = item.Description
            });

            await db.ExecuteAsync(finalSql);
        }
    }

    // ------------------------------------------------------------
    // Сохранение пользователей (по username)
    // ------------------------------------------------------------
    private async Task SaveUsersAsync(
        NestedTransactionConnection db,
        string clientId,
        List<UserDto> users)
    {
        foreach (var user in users)
        {
            var sql = $@"
                INSERT INTO {db.Factory.Schema}.users
                    (client_id, username)
                VALUES
                    (@ClientId, @Username)
                ON CONFLICT (client_id, username)
                DO NOTHING;
            ";

            var finalSql = db.Factory.BuildSql(sql, new
            {
                ClientId = clientId,
                Username = user.Username
            });

            await db.ExecuteAsync(finalSql);
        }
    }

    // ------------------------------------------------------------
    // Сохранение свойств пользователя (по username)
    // ------------------------------------------------------------
    private async Task SaveUserPropertiesAsync(
    NestedTransactionConnection db,
    string clientId,
    string username,
    Dictionary<string, object> props)
    {
        foreach (var kv in props)
        {
            var sql = $@"
            INSERT INTO {db.Factory.Schema}.user_properties
                (client_id, username, property_code, value, updated_at)
            VALUES
                (@ClientId, @Username, @PropertyCode, @Value::jsonb, now())
            ON CONFLICT (client_id, username, property_code)
            DO UPDATE SET
                value = EXCLUDED.value,
                updated_at = now();
        ";

            var finalSql = db.Factory.BuildSql(sql, new
            {
                ClientId = clientId,
                Username = username,
                PropertyCode = kv.Key,
                Value = JsonSerializer.Serialize(kv.Value)
            });

            await db.ExecuteAsync(finalSql);
        }
    }

}
