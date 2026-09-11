namespace AccessControl.Core.WebSockets.RpcModels;

public class UserPropertiesResponse
{
    public string UserId { get; set; } = default!;
    public Dictionary<string, object> Properties { get; set; } = new();
}
