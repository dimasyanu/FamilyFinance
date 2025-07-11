using FamilyFinance.Abstractions;
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
    [Route("{userId:guid}")]
    public async Task<ActionResult<UserDto>> Get(Guid userId)
    {
        var user = await _service.GetUserByIdAsync(userId);
        if (user == null) return NotFound();
        return Ok(user);
    }

    [HttpPost]
    [Route("")]
    public async Task<ActionResult<Response<CreationResponse>>> Create([FromBody] UserSaveRequest request)
    {
        if (request == null) return BadRequest("Request cannot be null.");
        if (!ModelState.IsValid) return BadRequest(ModelState);

        var currentUser = await GetCurrentUser();

        var id = await _service.CreateUserAsync(request, currentUser.Id);
        return Ok(new CreationResponse(id), "User created successfully");
    }

    [HttpPut]
    [Route("{userId:guid}")]
    public async Task<ActionResult<Response<UserDto>>> Update(Guid userId, [FromBody] UserSaveRequest request)
    {
        if (request == null) return BadRequest("Request cannot be null.");
        if (!ModelState.IsValid) return BadRequest(ModelState);

        var currentUser = await GetCurrentUser();

        var item = await _service.UpdateUserAsync(userId, request, currentUser.Id);
        return Ok(item, "User updated successfully.");
    }

    [HttpDelete]
    [Route("{userId:guid}")]
    public async Task<ActionResult> Delete(Guid userId)
    {
        var user = await GetCurrentUser();
        await _service.DeleteUserAsync(userId, user.Id);
        return Ok("User deleted successfully.");
    }

    [HttpPut]
    [Route("{userId:guid}/Restore")]
    public async Task<ActionResult> Restore(Guid userId)
    {
        var currentUserId = await GetCurrentUser();
        await _service.RestoreAsync(userId, currentUserId.Id);
        return Ok("User restored successfully.");
    }
}
