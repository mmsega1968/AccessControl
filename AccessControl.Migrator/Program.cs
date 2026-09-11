using Microsoft.Extensions.Configuration;
using Npgsql;
using System.IO;
using System.Linq;
using System.Threading.Tasks;

class Program
{
    static async Task Main(string[] args)
    {
        var exeDir = AppContext.BaseDirectory;

        // --- Чтение конфига рядом с EXE ---
        var config = new ConfigurationBuilder()
            .SetBasePath(exeDir)
            .AddJsonFile("appsettings.json", optional: false)
            .Build();

        // --- Параметры БД ---
        var db = config.GetSection("Database");

        var host = db["Host"];
        var port = db["Port"];
        var name = db["Name"];
        var user = db["Username"];
        var pass = db["Password"];
        var schema = db["Schema"];

        var connStr =
            $"Host={host};Port={port};Database={name};Username={user};Password={pass}";

        // --- Абсолютный путь к версиям ---
        var versionsPathRaw = config["Migrator:VersionsPath"];
        var versionsPath = Path.GetFullPath(versionsPathRaw);

        Console.WriteLine($"[DBMigrator] Подключение: {connStr}");
        Console.WriteLine($"[DBMigrator] Схема: {schema}");
        Console.WriteLine($"[DBMigrator] Путь версий: {versionsPath}");

        // --- Проверка существования таблицы db_version ---
        var versionTableExists = await CheckVersionTableExists(connStr, schema);

        if (!versionTableExists)
        {
            Console.WriteLine("[DBMigrator] Таблица db_version отсутствует → применяем 001...");
            await ApplyVersion(connStr, schema, versionsPath, "001");
            Console.WriteLine("[DBMigrator] Версия 001 применена.");
            return;
        }

        // --- Текущая версия ---
        var currentVersion = await GetCurrentVersion(connStr, schema);
        Console.WriteLine($"[DBMigrator] Текущая версия: {currentVersion}");

        // --- Список папок версий ---
        var versionFolders = Directory.GetDirectories(versionsPath)
            .Select(Path.GetFileName)
            .OrderBy(v => v)
            .ToList();

        foreach (var version in versionFolders)
        {
            if (string.Compare(version, currentVersion) <= 0)
                continue;

            Console.WriteLine($"[DBMigrator] Применяем {version}...");
            await ApplyVersion(connStr, schema, versionsPath, version);
            Console.WriteLine($"[DBMigrator] Версия {version} применена.");
        }

        Console.WriteLine("[DBMigrator] Миграции завершены.");
    }

    static async Task ApplyVersion(string connStr, string schema, string versionsPath, string version)
    {
        var sqlFile = Path.Combine(versionsPath, version, "upgrade.sql");

        if (!File.Exists(sqlFile))
            throw new FileNotFoundException($"upgrade.sql не найден для версии {version}");

        var sql = File.ReadAllText(sqlFile).Replace("{{schema}}", schema);

        await ExecuteSql(connStr, sql);
        await InsertVersion(connStr, schema, version);
    }

    static async Task<bool> CheckVersionTableExists(string connStr, string schema)
    {
        using var conn = new NpgsqlConnection(connStr);
        await conn.OpenAsync();

        var cmd = new NpgsqlCommand(
            "SELECT EXISTS (" +
            "SELECT 1 FROM information_schema.tables " +
            "WHERE table_schema = @schema AND table_name = 'db_version');",
            conn);

        cmd.Parameters.AddWithValue("schema", schema);

        return (bool)await cmd.ExecuteScalarAsync();
    }

    static async Task<string> GetCurrentVersion(string connStr, string schema)
    {
        using var conn = new NpgsqlConnection(connStr);
        await conn.OpenAsync();

        var cmd = new NpgsqlCommand(
            $"SELECT version FROM {schema}.db_version ORDER BY applied_at DESC LIMIT 1;",
            conn);

        return (string?)await cmd.ExecuteScalarAsync() ?? "000";
    }

    static async Task InsertVersion(string connStr, string schema, string version)
    {
        using var conn = new NpgsqlConnection(connStr);
        await conn.OpenAsync();

        var cmd = new NpgsqlCommand(
            $"INSERT INTO {schema}.db_version(version) VALUES (@v) " +
            "ON CONFLICT (version) DO NOTHING;",
            conn);

        cmd.Parameters.AddWithValue("v", version);

        await cmd.ExecuteNonQueryAsync();
    }

    static async Task ExecuteSql(string connStr, string sql)
    {
        using var conn = new NpgsqlConnection(connStr);
        await conn.OpenAsync();

        using var cmd = new NpgsqlCommand(sql, conn);
        await cmd.ExecuteNonQueryAsync();
    }
}
