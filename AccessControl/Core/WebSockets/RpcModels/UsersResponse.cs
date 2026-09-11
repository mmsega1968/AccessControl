namespace AccessControl.Core.WebSockets.RpcModels;

public class UsersResponse
{
    public List<UserDto> Users { get; set; } = new();
}
