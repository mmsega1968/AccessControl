using AccessControl.Core.WebSockets.RpcModels;

namespace AccessControl.Core.WebSockets.RpcModels;

public class PropertyDictionaryResponse
{
    public List<PropertyDto> PropertyDictionary { get; set; } = new();
}
