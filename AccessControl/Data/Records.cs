using System.Text.Json.Serialization;

namespace AccessControl.Data.Records;

// ---------------- USERS ----------------

public class UserRecord
{
    [JsonPropertyName("id")]
    public Guid Id { get; set; }

    [JsonPropertyName("username")]
    public string Username { get; set; } = string.Empty;

    // Если понадобится — добавим DepartmentId, Email, DisplayName и т.д.
    // Сейчас оставляем минимальный набор.
}


//------------------ USER PROPERTIES INFO ____

public class UserPropertyDictionaryRecord
{
    public Guid Id { get; set; }

    public string ClientId { get; set; } = default!;

    public string PropertyCode { get; set; } = string.Empty;

    public string Title { get; set; } = string.Empty;

    public string Type { get; set; } = string.Empty;

    public bool IsRequired { get; set; }

    public string? DefaultValue { get; set; }

    public string? Description { get; set; }
}

public class UserPropertyRecord
{
    public Guid UserId { get; set; }
    public string PropertyCode { get; set; } = string.Empty;
    public string Value { get; set; } = string.Empty;
}


// ---------------- ROLES ----------------

public class RoleRecord
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
}

public class RightRecord
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
}

// ---------------- RELATIONS ----------------

public class UserRoleRecord
{
    public Guid UserId { get; set; }
    public Guid RoleId { get; set; }
}

public class RoleRightRecord
{
    public Guid RoleId { get; set; }
    public Guid RightId { get; set; }
}

public class RoleIncludeRecord
{
    public Guid ParentRoleId { get; set; }
    public Guid ChildRoleId { get; set; }
}

// ---------------- OUTBOUND ----------------

public class ExternalRequestRecord
{
    public Guid Id { get; set; }

    public string ClientId { get; set; } = default!;

    public string Action { get; set; } = default!;

    // payload хранится в БД как jsonb → в C# это string
    public string Payload { get; set; } = default!;

    // status хранится в БД как text → в C# это string
    public string Status { get; set; } = default!;

    public DateTime CreatedAt { get; set; }

    public DateTime UpdatedAt { get; set; }
}


public class ExternalRequestResponseRecord
{
    public Guid Id { get; set; }
    public Guid RequestId { get; set; }
    public string Payload { get; set; } = default!;
    public DateTime CreatedAt { get; set; }
}
