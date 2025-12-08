using FamilyFinance.ActionFilters;
using FamilyFinance.Models.Dtos;
using FamilyFinance.Models.Requests;
using FamilyFinance.Models.Requests.ListFilters;
using FamilyFinance.Models.Responses;
using FamilyFinance.Models.Responses.ListItems;
using FamilyFinance.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FamilyFinance.Controllers;

[ApiController]
[Authorize]
[AuthUser]
[Route("Api/Users")]
public class AccountController(AccountService service) : BaseController
{
    private readonly AccountService _service = service ?? throw new ArgumentNullException(nameof(service));

    [HttpGet]
    [Route("{userId:int}/Accounts")]
    public async Task<ActionResult<Paginated<AccountListItem>>> AccountList(int userId, [FromQuery] AccountListFilter filter)
    {
        var results = await _service.ListAsync(userId, filter);
        return Ok(results);
    }

    [HttpGet]
    [Route("{userId:int}/Accounts/{accountId:int}")]
    public async Task<ActionResult<AccountDto>> GetAccount(int userId, int accountId)
    {
        var account = await _service.Get(userId, accountId);
        return Ok(account);
    }

    [HttpPost]
    [Route("{userId:int}/Accounts")]
    public async Task<ActionResult<Response<AccountDto>>> CreateAccount(int userId, [FromBody] AccountSaveRequest request)
    {
        if (request == null) return BadRequest("Request cannot be null.");
        if (!ModelState.IsValid) return BadRequest(ModelState);

        var account = await _service.CreateAsync(userId, request, CurrentUser.Id);
        return Created(account, "Account created successfully");
    }

    [HttpPatch]
    [Route("{userId:int}/Accounts/{accountId:int}")]
    public async Task<ActionResult<Response<AccountDto>>> UpdateAccount(int userId, int accountId, [FromBody] AccountSaveRequest request)
    {
        if (request == null) return BadRequest("Request cannot be null.");
        if (!ModelState.IsValid) return BadRequest(ModelState);

        var account = await _service.UpdateAsync(userId, accountId, request, CurrentUser.Id);
        return Ok(account, "Account updated successfully");
    }

    [HttpDelete]
    [Route("{userId:int}/Accounts/{accountId:int}")]
    public async Task<ActionResult> DeleteAccount(int userId, int accountId)
    {
        await _service.DeleteAsync(userId, accountId, CurrentUser.Id);
        return Ok("Account deleted successfully");
    }

    [HttpPut]
    [Route("{userId:int}/Accounts/{accountId:int}/Restore")]
    public async Task<ActionResult<Response<AccountDto>>> RestoreAccount(int userId, int accountId)
    {
        var account = await _service.RestoreAsync(userId, accountId, CurrentUser.Id);
        return Ok(account, "Account restored successfully");
    }
}
