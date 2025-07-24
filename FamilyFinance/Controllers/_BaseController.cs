using FamilyFinance.Abstractions;
using FamilyFinance.Models.Dtos;
using FamilyFinance.Models.Responses;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using System.Security.Claims;

namespace FamilyFinance.Controllers;

public abstract class BaseController : ControllerBase
{
    protected UserDto CurrentUser { get; private set; } = new();

    internal virtual void CheckCurrentUser()
    {
        CurrentUser = GetCurrentUser().GetAwaiter().GetResult();
        if (CurrentUser == null || CurrentUser.Id == Guid.Empty || CurrentUser.Username.IsNullOrEmpty())
        {
            throw new UnauthorizedAccessException();
        }
    }

    private async Task<UserDto> GetCurrentUser()
    {
        var username = User.FindFirstValue(ClaimTypes.Name);
        if (string.IsNullOrEmpty(username)) throw new UnauthorizedAccessException();

        var userService = HttpContext.RequestServices.GetRequiredService<IUserService>();

        var currentUser = await userService.GetUserByUsernameAsync(username)
            ?? throw new UnauthorizedAccessException("User not found");

        return currentUser;
    }

    public OkObjectResult Ok<T>(T? value, string message = "Success") where T : class
        => base.Ok(new Response<object>
        {
            Success = true,
            Message = message,
            Data = value
        });

    public CreatedResult Created<T>(T? value, string message = "Created") where T : class
        => base.Created("", new Response<object>
        {
            Success = true,
            Message = message,
            Data = value
        });
}
