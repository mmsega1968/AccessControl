using Microsoft.AspNetCore.Mvc;

namespace AccessControl.Controllers.RoleModel;

[ApiController]
[Route("api/roles")]
public class RolesController : ControllerBase
{
    private readonly IRoleService _service;

    public RolesController(IRoleService service)
    {
        _service = service;
    }

    // ---------------------------------------------------------
    // GET /api/roles?clientId=xxx
    // ---------------------------------------------------------
    [HttpGet]
    public async Task<IActionResult> GetRoles([FromQuery] string clientId)
    {
        var roles = await _service.GetRolesAsync(clientId);
        return Ok(roles);
    }

    // ---------------------------------------------------------
    // GET /api/roles/{clientId}/{roleCode}
    // ---------------------------------------------------------
    [HttpGet("{clientId}/{roleCode}")]
    public async Task<IActionResult> GetRole(string clientId, string roleCode)
    {
        var role = await _service.GetRoleAsync(clientId, roleCode);
        if (role == null)
            return NotFound();

        return Ok(role);
    }

    // ---------------------------------------------------------
    // POST /api/roles
    // ---------------------------------------------------------
    [HttpPost]
    public async Task<IActionResult> CreateRole([FromBody] RoleDto dto)
    {
        var created = await _service.CreateRoleAsync(dto);
        return CreatedAtAction(nameof(GetRole),
            new { clientId = created.client_id, roleCode = created.role_code },
            created);
    }

    // ---------------------------------------------------------
    // PUT /api/roles/{clientId}/{roleCode}
    // ---------------------------------------------------------
    [HttpPut("{clientId}/{roleCode}")]
    public async Task<IActionResult> UpdateRole(
        string clientId,
        string roleCode,
        [FromBody] RoleDto dto)
    {
        var updated = await _service.UpdateRoleAsync(clientId, roleCode, dto);
        if (updated == null)
            return NotFound();

        return Ok(updated);
    }

    // ---------------------------------------------------------
    // DELETE /api/roles/{clientId}/{roleCode}
    // ---------------------------------------------------------
    [HttpDelete("{clientId}/{roleCode}")]
    public async Task<IActionResult> RetireRole(string clientId, string roleCode)
    {
        var ok = await _service.RetireRoleAsync(clientId, roleCode);
        if (!ok)
            return NotFound();

        return NoContent();
    }
}
