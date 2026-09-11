using AccessControl.Core;
using AccessControl.Core.Sync;
using AccessControl.Core.WebSockets;
using AccessControl.Data;
using AccessControl.Database;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Npgsql;
using OpenTelemetry.Metrics;
using OpenTelemetry.Resources;

var builder = WebApplication.CreateBuilder(args);

// -----------------------------
// 1. Загрузка локального конфига
// -----------------------------
var moduleDir = AppContext.BaseDirectory;

builder.Configuration
    .SetBasePath(moduleDir)
    .AddJsonFile("appsettings.json", optional: false);

// -----------------------------
// 2. Настройка стандартного логирования
// -----------------------------

AppContext.SetSwitch("Npgsql.EnableOpenTelemetry", true);

builder.Logging.ClearProviders();
builder.Logging.AddConsole();
builder.Logging.AddDebug();
builder.Logging.AddFile("logs/app.log");
builder.Logging.AddFilter("Npgsql", LogLevel.Debug);

// -----------------------------
// 2.1 OpenTelemetry Metrics
// -----------------------------
builder.Services.AddOpenTelemetry()
    .WithMetrics(metrics =>
    {
        metrics.SetResourceBuilder(
            ResourceBuilder.CreateDefault().AddService("AccessControl"));

        metrics.AddMeter("Npgsql");
        metrics.AddMeter("Npgsql.Command");
        metrics.AddMeter("Npgsql.Connection");

        metrics.AddConsoleExporter(options =>
        {
            options.Targets = OpenTelemetry.Exporter.ConsoleExporterOutputTargets.Console;
        });
    });

// -----------------------------
// 3. Регистрация сервисов
// -----------------------------

// База данных
builder.Services.AddSingleton<DbConnectionFactory>();

// WebSockets gateway
builder.Services.AddSingleton<IWebSocketGateway, WebSocketGateway>();

// WebSocket RPC (нужен ClientSyncService)
builder.Services.AddSingleton<WebSocketRpcService>();

// Репозитории
builder.Services.AddScoped<UserRepository>();

// Sync API
builder.Services.AddScoped<ClientSyncService>();


//редактирование ролевой модели
builder.Services.AddScoped<IRoleService, RoleService>();


builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// -----------------------------
// 4. Проверка версии БД
// -----------------------------
using (var scope = app.Services.CreateScope())
{
    var logger = scope.ServiceProvider.GetRequiredService<ILogger<Program>>();
    var factory = scope.ServiceProvider.GetRequiredService<DbConnectionFactory>();

    try
    {
        await using var conn = factory.Create();

        logger.LogInformation("[Startup] Соединение с БД установлено успешно.");

        var checker = factory.CreateVersionChecker();
        await checker.EnsureVersionAsync(conn);

        var version = await checker.GetCurrentVersionAsync(conn);
        logger.LogInformation("[Startup] Версия БД корректна: {Version}", version);
    }
    catch (Exception ex)
    {
        logger.LogCritical(ex, "[Startup] Ошибка проверки БД");
        throw;
    }
}

// -----------------------------
// 5. HTTP pipeline
// -----------------------------
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseWebSockets();

app.Map("/ws", async context =>
{
    var gateway = context.RequestServices.GetRequiredService<IWebSocketGateway>();
    await gateway.HandleClientAsync(context);
});

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();
app.Run();
