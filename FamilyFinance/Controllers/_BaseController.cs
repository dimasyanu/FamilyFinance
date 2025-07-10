using FamilyFinance.Models.Dtos;
using FamilyFinance.Models.Responses;
using FamilyFinance.Services;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace FamilyFinance.Controllers;

public abstract class BaseController : ControllerBase
{
    protected async Task<UserDto> GetCurrentUser()
    {
        var username = User.FindFirstValue("username");
        if (string.IsNullOrEmpty(username)) throw new UnauthorizedAccessException();

        var userService = HttpContext.RequestServices.GetRequiredService<UserService>();

        var user = await userService.GetUserByUsernameAsync(username)
            ?? throw new UnauthorizedAccessException("User not found");

        return user;
    }

    public OkObjectResult Ok<T>(T? value, string message = "Success") where T : class
        => base.Ok(new Response<object> {
            Success = true,
            Message = message,
            Data = value
        });
}
