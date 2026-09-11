namespace AccessControl.Core.WebSockets.RpcModels;

public class PropertyDto
{
    public string Id { get; set; } = default!;
    public string PropertyCode { get; set; } = default!;
    public string Title { get; set; } = default!;
    public string Type { get; set; } = default!;
    public bool IsRequired { get; set; }
    public object? DefaultValue { get; set; }
    public string? Description { get; set; }
}
