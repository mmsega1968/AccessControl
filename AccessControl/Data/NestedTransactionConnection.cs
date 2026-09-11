using AccessControl.Database;
using Dapper;
using Npgsql;
using System.Data;

public class NestedTransactionConnection : IDisposable, IAsyncDisposable
{
    private readonly NpgsqlConnection _conn;
    private readonly ILogger _logger;

    public DbConnectionFactory Factory { get; }

    private NpgsqlTransaction? _tx;
    private int _depth = 0;

    public NestedTransactionConnection(
        NpgsqlConnection conn,
        DbConnectionFactory factory,
        ILogger logger)
    {
        _conn = conn;
        Factory = factory;
        _logger = logger;
    }

    private bool ShouldLog(LogLevel level)
    {
        return Factory.SqlLoggingEnabled && Factory.SqlLoggingLevel <= level;
    }

    public NpgsqlConnection Raw => _conn;

    // ------------------------------------------------------------
    // DAPPER API — единая точка доступа к БД
    // ------------------------------------------------------------
    public async Task<int> ExecuteAsync(string sql, object? parameters = null)
    {
        if (ShouldLog(LogLevel.Debug))
            _logger.LogDebug("[NestedTx] EXECUTE: {Sql}", sql);

        return await _conn.ExecuteAsync(sql, parameters, _tx);
    }

    public async Task<T> QuerySingleAsync<T>(string sql, object? parameters = null)
    {
        if (ShouldLog(LogLevel.Debug))
            _logger.LogDebug("[NestedTx] QUERY SINGLE: {Sql}", sql);

        return await _conn.QuerySingleAsync<T>(sql, parameters, _tx);
    }

    public async Task<IEnumerable<T>> QueryAsync<T>(string sql, object? parameters = null)
    {
        if (ShouldLog(LogLevel.Debug))
            _logger.LogDebug("[NestedTx] QUERY: {Sql}", sql);

        return await _conn.QueryAsync<T>(sql, parameters, _tx);
    }

    public async Task<T?> QueryFirstOrDefaultAsync<T>(string sql, object? parameters = null)
    {
        if (ShouldLog(LogLevel.Debug))
            _logger.LogDebug("[NestedTx] QUERY FIRST OR DEFAULT: {Sql}", sql);

        return await _conn.QueryFirstOrDefaultAsync<T>(sql, parameters, _tx);
    }

    public async Task<T?> QuerySingleOrDefaultAsync<T>(string sql, object? parameters = null)
    {
        _logger.LogDebug($"[NestedTx] QUERY SINGLE OR DEFAULT: {sql}");
        return await _conn.QuerySingleOrDefaultAsync<T>(sql, parameters, _tx);
    }


    // ------------------------------------------------------------
    // BEGIN TRANSACTION
    // ------------------------------------------------------------
    public async Task BeginTranAsync()
    {
        if (_depth == 0)
        {
            if (ShouldLog(LogLevel.Information))
                _logger.LogInformation("[NestedTx] BEGIN (real)");

            _tx = await _conn.BeginTransactionAsync();
        }
        else
        {
            if (ShouldLog(LogLevel.Debug))
                _logger.LogDebug("[NestedTx] BEGIN (nested level {Depth})", _depth + 1);
        }

        _depth++;
    }

    // ------------------------------------------------------------
    // COMMIT
    // ------------------------------------------------------------
    public async Task CommitAsync()
    {
        if (_depth == 0)
        {
            _logger.LogError("[NestedTx] Commit called without active transaction");
            throw new InvalidOperationException("Commit without BeginTran");
        }

        _depth--;

        if (_depth == 0)
        {
            if (ShouldLog(LogLevel.Information))
                _logger.LogInformation("[NestedTx] COMMIT (real)");

            await _tx!.CommitAsync();
            await _tx.DisposeAsync();
            _tx = null;
        }
        else
        {
            if (ShouldLog(LogLevel.Debug))
                _logger.LogDebug("[NestedTx] COMMIT (nested, remaining depth {Depth})", _depth);
        }
    }

    // ------------------------------------------------------------
    // ROLLBACK
    // ------------------------------------------------------------
    public async Task RollbackAsync()
    {
        if (_tx != null)
        {
            if (ShouldLog(LogLevel.Warning))
                _logger.LogWarning("[NestedTx] ROLLBACK (real)");

            await _tx.RollbackAsync();
            await _tx.DisposeAsync();
            _tx = null;
        }
        else
        {
            if (ShouldLog(LogLevel.Warning))
                _logger.LogWarning("[NestedTx] ROLLBACK ignored (no active transaction)");
        }

        _depth = 0;
    }

    // ------------------------------------------------------------
    // ASYNC DISPOSE
    // ------------------------------------------------------------
    public async ValueTask DisposeAsync()
    {
        if (ShouldLog(LogLevel.Debug))
            _logger.LogDebug("[NestedTx] DisposeAsync");

        try
        {
            if (_tx != null)
            {
                await _tx.DisposeAsync();
                _tx = null;
            }

            if (_conn.FullState != ConnectionState.Closed)
                await _conn.CloseAsync();

            await _conn.DisposeAsync();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "[NestedTx] Ошибка при DisposeAsync");
        }
    }

    // ------------------------------------------------------------
    // SYNC DISPOSE
    // ------------------------------------------------------------
    public void Dispose()
    {
        if (ShouldLog(LogLevel.Debug))
            _logger.LogDebug("[NestedTx] Dispose");

        try
        {
            _tx?.Dispose();
            _tx = null;

            if (_conn.FullState != ConnectionState.Closed)
                _conn.Close();

            _conn.Dispose();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "[NestedTx] Error during Dispose");
        }
    }
}
