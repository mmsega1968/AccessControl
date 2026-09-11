using Microsoft.AspNetCore.Mvc;

namespace AccessControl.Controllers.Admin;

[ApiController]
[Route("api/admin/panel")]
public class AdminPanelController : ControllerBase
{
    [HttpGet("status")]
    public IActionResult Status()
    {
        return Ok(new { status = "OK" });
    }
}
