public class RoleDto
{
    public string client_id { get; set; } = default!;
    public string role_code { get; set; } = default!;
    public string role_name { get; set; } = default!;
    public bool is_active { get; set; } = true;
}
