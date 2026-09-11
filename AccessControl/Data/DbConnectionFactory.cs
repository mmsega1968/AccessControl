using AccessControl.Core;
using Npgsql;
using System.Reflection;

namespace AccessControl.Database;

public class DbConnectionFactory
{
    public string ConnectionString { get; }
    public string Schema { get; }

    private readonly NpgsqlDataSource _dataSource;
    private readonly ILogger<DbConnectionFactory> _logger;

    // Новые настройки SQL‑логирования
    public bool SqlLoggingEnabled { get; }
    public LogLevel SqlLoggingLevel { get; }

    public DbConnectionFactory(IConfiguration config, ILogger<DbConnectionFactory> logger)
    {
        _logger = logger;

        // -----------------------------
        // Чтение настроек SQL‑логирования
        // -----------------------------
        var sqlLog = config.GetSection("Logging:Sql");

        SqlLoggingEnabled = sqlLog.GetValue<bool>("Enabled", true);
        SqlLoggingLevel = Enum.TryParse<LogLevel>(
            sqlLog.GetValue<string>("Level") ?? "Debug",
            out var level)
            ? level
            : LogLevel.Debug;

        // -----------------------------
        // Настройки БД
        // -----------------------------
        var db = config.GetSection("Database");

        var host = db["Host"];
        var port = db["Port"];
        var name = db["Name"];
        var user = db["Username"];
        var pass = db["Password"];

        Schema = string.IsNullOrWhiteSpace(db["Schema"])
            ? "public"
            : db["Schema"];

        ConnectionString =
            $"Host={host};Port={port};Database={name};Username={user};Password={pass};Pooling=true;Maximum Pool Size=50;";

        // Создаём DataSource — пул живёт здесь
        _dataSource = NpgsqlDataSource.Create(ConnectionString);
    }

    // ============================================================
    // CONNECTIONS
    // ============================================================

    public NpgsqlConnection Create()
    {
        return _dataSource.OpenConnection();
    }

    public async Task<NpgsqlConnection> CreateAsync()
    {
        return await _dataSource.OpenConnectionAsync();
    }

    public NestedTransactionConnection CreateNested(ILogger logger)
    {
        return new NestedTransactionConnection(_dataSource.OpenConnection(), this, logger);
    }

    public async Task<NestedTransactionConnection> CreateNestedAsync(ILogger logger)
    {
        var conn = await _dataSource.OpenConnectionAsync();
        return new NestedTransactionConnection(conn, this, logger);
    }

    public DbVersionChecker CreateVersionChecker()
    {
        return new DbVersionChecker(ConnectionString, Schema, DbVersion.Required, _logger);
    }

    // ============================================================
    // SQL BUILDER
    // ============================================================

    public string BuildSql(string sqlTemplate, object parameters)
    {
        var dict = parameters
            .GetType()
            .GetProperties(BindingFlags.Public | BindingFlags.Instance)
            .ToDictionary(
                p => p.Name,
                p => p.GetValue(parameters)
            );

        foreach (var kv in dict)
        {
            var name = kv.Key;
            var value = kv.Value;

            string formatted = value switch
            {
                null => "NULL",
                Guid g => $"'{g}'",
                DateTime dt => $"'{dt:yyyy-MM-dd HH:mm:ss}'",
                string s => $"'{s.Replace("'", "''")}'",
                _ => $"'{value?.ToString()?.Replace("'", "''")}'"
            };

            sqlTemplate = sqlTemplate.Replace($"@{name}", formatted);
        }

        // Логирование через конфиг
        if (SqlLoggingEnabled && SqlLoggingLevel <= LogLevel.Debug)
        {
            _logger.LogDebug("=== SQL BUILDER OUTPUT ===\n{Sql}\n==========================", sqlTemplate);
        }

        return sqlTemplate;
    }
}