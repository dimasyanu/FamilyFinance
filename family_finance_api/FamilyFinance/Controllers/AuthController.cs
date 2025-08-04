using FamilyFinance.Models.Requests;
using FamilyFinance.Models.Responses;
using FamilyFinance.Services;
using Microsoft.AspNetCore.Mvc;

namespace FamilyFinance.Controllers;

[ApiController]
[Route("Api/[controller]")]
public class AuthController(AuthService authService) : BaseController
{
    private readonly AuthService _authService = authService;

    [HttpPost]
    [Route("[action]")]
    public async Task<ActionResult<Response<LoginResponse>>> Login(LoginRequest login)
    {
        var result = await _authService.Authenticate(login);
        if (result is null) return Unauthorized();
        return Ok(result);
    }

    [HttpPost]
    [Route("[action]")]
    public async Task<ActionResult<Response<RefreshTokenResponse>>> RefreshToken(RefreshTokenRequest request)
    {
        var result = await _authService.RefreshToken(request);
        if (result is null) return Unauthorized();
        return Ok(result);
    }
}
