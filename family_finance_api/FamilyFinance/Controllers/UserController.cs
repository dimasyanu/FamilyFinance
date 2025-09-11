using FamilyFinance.Abstractions;
using FamilyFinance.ActionFilters;
using FamilyFinance.Models.Dtos;
using FamilyFinance.Models.Requests;
using FamilyFinance.Models.Requests.ListFilters;
using FamilyFinance.Models.Responses;
using FamilyFinance.Models.Responses.ListItems;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FamilyFinance.Controllers;

[ApiController]
[Authorize]
[AuthUser]
[Route("Api/Users")]
public class UserController(IUserService service) : BaseController
{
    private readonly IUserService _service = service ?? throw new ArgumentNullException(nameof(service));

    [HttpGet]
    [Route("")]
    public async Task<ActionResult<Paginated<UserListItem>>> List([FromQuery]UserListFilter filter)
    {
        var results = await _service.ListAsync(filter);
        return Ok(results);
    }

    [HttpGet]
    [Route("{userId:int}")]
    public async Task<ActionResult<UserDto>> Get(int userId)
    {
        var user = await _service.GetUserByIdAsync(userId);
        if (user == null) return NotFound();
        return Ok(user);
    }

    [HttpPost]
    [Route("")]
    public async Task<ActionResult<Response<CreationResponse<int>>>> Create([FromBody] UserSaveRequest request)
    {
        if (request == null) return BadRequest("Request cannot be null.");
        if (!ModelState.IsValid) return BadRequest(ModelState);

        var id = await _service.CreateUserAsync(request, CurrentUser.Id);
        return Ok(new CreationResponse<int>(id), "User created successfully");
    }

    [HttpPatch]
    [Route("{userId:int}")]
    public async Task<ActionResult<Response<UserDto>>> Update(int userId, [FromBody] UserSaveRequest request)
    {
        if (request == null) return BadRequest("Request cannot be null.");
        if (!ModelState.IsValid) return BadRequest(ModelState);

        var item = await _service.UpdateUserAsync(userId, request, CurrentUser.Id);
        return Ok(item, "User updated successfully.");
    }

    [HttpDelete]
    [Route("{userId:int}")]
    public async Task<ActionResult> Delete(int userId)
    {
        await _service.DeleteUserAsync(userId, CurrentUser.Id);
        return Ok("User deleted successfully.");
    }

    [HttpPut]
    [Route("{userId:int}/Restore")]
    public async Task<ActionResult> Restore(int userId)
    {
        await _service.RestoreAsync(userId, CurrentUser.Id);
        return Ok("User restored successfully.");
    }
}
