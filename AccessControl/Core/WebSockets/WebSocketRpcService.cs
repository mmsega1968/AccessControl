using System.Text.Json;

public class WebSocketRpcService
{
    private readonly IWebSocketGateway _gateway;

    public WebSocketRpcService(IWebSocketGateway gateway)
    {
        _gateway = gateway;
    }

    public async Task<TResponse> CallAsync<TResponse>(
        string clientId,
        string action,
        object payload)
    {
        var requestId = Guid.NewGuid().ToString();

        var tcs = new TaskCompletionSource<string>();
        _gateway.RegisterPending(requestId, tcs);

        var request = new
        {
            type = "request",
            requestId,
            action,
            payload
        };

        // отправка запроса
        var socket = _gateway.GetClientSocket(clientId)
            ?? throw new Exception($"Client '{clientId}' is not connected");

        var json = JsonSerializer.Serialize(request);
        //await _gateway.SendAsync(socket, json);
        await _gateway.SendAsync(clientId, request);

        // ожидание ответа
        var responseJson = await tcs.Task;

        using var doc = JsonDocument.Parse(responseJson);
        var payloadJson = doc.RootElement.GetProperty("payload");

        var options = new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true
        };

        return JsonSerializer.Deserialize<TResponse>(payloadJson.GetRawText(), options)!;

    }
}
