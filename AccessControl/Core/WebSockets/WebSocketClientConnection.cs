using System.Net.WebSockets;
using System.Text;
using System.Text.Json;

namespace AccessControl.Core.WebSockets;

public class WebSocketClientConnection
{
    public string ClientId { get; }
    public WebSocket Socket { get; }

    public WebSocketClientConnection(string clientId, WebSocket socket)
    {
        ClientId = clientId;
        Socket = socket;
    }

    public async Task SendAsync(object message)
    {
        var json = JsonSerializer.Serialize(message);
        var bytes = Encoding.UTF8.GetBytes(json);

        await Socket.SendAsync(
            new ArraySegment<byte>(bytes),
            WebSocketMessageType.Text,
            true,
            CancellationToken.None
        );
    }
}
