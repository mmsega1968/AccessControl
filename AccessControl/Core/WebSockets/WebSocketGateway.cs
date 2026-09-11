using System.Collections.Concurrent;
using System.Net.WebSockets;
using System.Text;
using System.Text.Json;

namespace AccessControl.Core.WebSockets;

public class WebSocketGateway : IWebSocketGateway
{
    private readonly ILogger<WebSocketGateway> _logger;

    // Активные клиенты
    private static readonly ConcurrentDictionary<string, WebSocket> _clients = new();

    // Ожидающие RPC-ответы
    private static readonly ConcurrentDictionary<string, TaskCompletionSource<string>> _pending =
        new();

    public WebSocketGateway(ILogger<WebSocketGateway> logger)
    {
        _logger = logger;
    }

    // ---------------------------
    //  ПОДКЛЮЧЕНИЕ КЛИЕНТА
    // ---------------------------
    public async Task HandleClientAsync(HttpContext context)
    {
        if (!context.WebSockets.IsWebSocketRequest)
        {
            context.Response.StatusCode = 400;
            return;
        }

        var socket = await context.WebSockets.AcceptWebSocketAsync();
        var clientId = context.Request.Query["clientId"].ToString();

        if (string.IsNullOrWhiteSpace(clientId))
        {
            await socket.CloseAsync(
                WebSocketCloseStatus.PolicyViolation,
                "clientId is required",
                CancellationToken.None
            );
            return;
        }

        _clients[clientId] = socket;

        _logger.LogInformation($"[WS] Клиент '{clientId}' подключён");

        await ReceiveLoopAsync(clientId, socket);
    }

    // ---------------------------
    //  ПОЛУЧЕНИЕ СООБЩЕНИЙ
    // ---------------------------
    private async Task ReceiveLoopAsync(string clientId, WebSocket socket)
    {
        var buffer = new byte[4096];

        while (socket.State == WebSocketState.Open)
        {
            using var ms = new MemoryStream();
            WebSocketReceiveResult result;

            try
            {
                do
                {
                    result = await socket.ReceiveAsync(
                        new ArraySegment<byte>(buffer),
                        CancellationToken.None);

                    ms.Write(buffer, 0, result.Count);

                } while (!result.EndOfMessage);
            }
            catch (Exception ex)
            {
                _logger.LogError($"[WS] Ошибка при получении данных от '{clientId}': {ex.Message}");
                break;
            }

            if (result.MessageType == WebSocketMessageType.Close)
            {
                _logger.LogInformation($"[WS] Клиент '{clientId}' отключён");
                _clients.TryRemove(clientId, out _);
                await socket.CloseAsync(WebSocketCloseStatus.NormalClosure, "Closed", CancellationToken.None);
                return;
            }

            var json = Encoding.UTF8.GetString(ms.ToArray());
            _logger.LogInformation($"[WS] Получено сообщение от '{clientId}': {json}");

            ProcessInboundMessage(json);
        }
    }

    // ---------------------------
    //  ОБРАБОТКА ВХОДЯЩЕГО RPC-ОТВЕТА
    // ---------------------------
    private void ProcessInboundMessage(string json)
    {
        try
        {
            var doc = JsonDocument.Parse(json);
            var root = doc.RootElement;

            if (root.TryGetProperty("type", out var typeProp) &&
                typeProp.GetString() == "response")
            {
                var requestId = root.GetProperty("requestId").GetString();

                if (requestId != null && _pending.TryRemove(requestId, out var tcs))
                {
                    tcs.SetResult(json);
                    return;
                }

                _logger.LogWarning($"[WS] Ответ с неизвестным requestId: {requestId}");
            }
            else
            {
                _logger.LogWarning($"[WS] Неизвестный тип сообщения: {json}");
            }
        }
        catch (Exception ex)
        {
            _logger.LogError($"[WS] Ошибка обработки входящего сообщения: {ex.Message}. Raw: {json}");
        }
    }

    // ---------------------------
    //  RPC: РЕГИСТРАЦИЯ ОЖИДАНИЯ
    // ---------------------------
    public void RegisterPending(string requestId, TaskCompletionSource<string> tcs)
    {
        _pending[requestId] = tcs;
    }

    // ---------------------------
    //  RPC: ПОЛУЧЕНИЕ СОКЕТА
    // ---------------------------
    public WebSocket? GetClientSocket(string clientId)
    {
        _clients.TryGetValue(clientId, out var socket);
        return socket;
    }

    // ---------------------------
    //  RPC: ОТПРАВКА СООБЩЕНИЯ
    // ---------------------------
    /*public async Task SendAsync(WebSocket socket, string json)
    {
        var bytes = Encoding.UTF8.GetBytes(json);
        await socket.SendAsync(bytes, WebSocketMessageType.Text, true, CancellationToken.None);
    }*/

    public async Task SendAsync(string clientId, object message)
    {
        if (!_clients.TryGetValue(clientId, out var socket))
            throw new Exception($"Client '{clientId}' is not connected");

        var json = JsonSerializer.Serialize(message);
        var bytes = Encoding.UTF8.GetBytes(json);

        await socket.SendAsync(bytes, WebSocketMessageType.Text, true, CancellationToken.None);
    }


    // ---------------------------
    //  ПРОВЕРКА СОСТОЯНИЯ
    // ---------------------------
    public bool IsClientConnected(string clientId)
    {
        return _clients.TryGetValue(clientId, out var socket)
               && socket.State == WebSocketState.Open;
    }
}
