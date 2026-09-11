public interface IRoleService
{
    Task<IEnumerable<RoleDto>> GetRolesAsync(string clientId);
    Task<RoleDto?> GetRoleAsync(string clientId, string roleCode);
    Task<RoleDto> CreateRoleAsync(RoleDto dto);
    Task<RoleDto?> UpdateRoleAsync(string clientId, string roleCode, RoleDto dto);
    Task<bool> RetireRoleAsync(string clientId, string roleCode);
}
