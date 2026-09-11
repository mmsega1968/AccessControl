using Npgsql;

namespace AccessControl.Database;

public class DbVersionChecker
{
    private readonly string _schema;
    private readonly string _requiredVersion;
    private readonly string _connectionString;
    private readonly ILogger _logger;

    public DbVersionChecker(string connectionString, string schema, string requiredVersion, ILogger logger)
    {
        _connectionString = connectionString;
        _schema = schema;
        _requiredVersion = requiredVersion;
        _logger = logger;
    }

    // ------------------------------------------------------------
    // Получение текущей версии БД
    // ------------------------------------------------------------
    public async Task<string?> GetCurrentVersionAsync(NpgsqlConnection conn)
    {
        var sql = $"SELECT version FROM {_schema}.db_version ORDER BY applied_at DESC LIMIT 1;";

        await using var cmd = new NpgsqlCommand(sql, conn);

        var current = (string?)await cmd.ExecuteScalarAsync();

        return current;
    }

    // ------------------------------------------------------------
    // Проверка версии
    // ------------------------------------------------------------
    public async Task EnsureVersionAsync(NpgsqlConnection conn)
    {
        var current = await GetCurrentVersionAsync(conn);

        if (current == null)
            throw new Exception("База данных не инициализирована.");

        if (current != _requiredVersion)
            throw new Exception(
                $"Версия БД ({current}) не соответствует требуемой. Запустите мигратор."
            );

        _logger.LogInformation($"[DbVersionChecker] Версия БД корректна: {current}");
    }
}
