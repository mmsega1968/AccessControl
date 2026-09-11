using System.Net.WebSockets;

public interface IWebSocketGateway
{
    bool IsClientConnected(string clientId);

    Task HandleClientAsync(HttpContext context);

    WebSocket? GetClientSocket(string clientId);

    //Task SendAsync(WebSocket socket, string json);
    Task SendAsync(string clientId, object message);

    void RegisterPending(string requestId, TaskCompletionSource<string> tcs);
}
