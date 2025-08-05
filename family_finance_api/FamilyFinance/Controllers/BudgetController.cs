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
[Route("Api/Budgets")]
public class BudgetController(BudgetService service) : BaseController
{
    [HttpGet]
    [Route("")]
    public async Task<ActionResult<Paginated<BudgetListItem>>> List([FromQuery] BudgetListFilter filter)
    {
        var results = await service.ListAsync(filter);
        return Ok(results);
    }

    [HttpGet]
    [Route("{budgetId:guid}")]
    public async Task<ActionResult<BudgetListItem>> Get(Guid budgetId)
    {
        var budget = await service.GetByIdAsync(budgetId);
        if (budget == null) return NotFound("Budget not found.");
        return Ok(budget);
    }

    [HttpPost]
    [Route("")]
    public async Task<ActionResult<Response<BudgetDto>>> Create([FromBody] BudgetSaveRequest request)
    {
        if (request == null) return BadRequest("Request cannot be null.");
        if (!ModelState.IsValid) return BadRequest(ModelState);
        var budget = await service.CreateAsync(request, CurrentUser.Id);
        return Created(budget, "Budget created successfully");
    }

    [HttpPut]
    [Route("{budgetId:guid}")]
    public async Task<ActionResult<Response<BudgetDto>>> Update(Guid budgetId, [FromBody] BudgetSaveRequest request)
    {
        if (request == null) return BadRequest("Request cannot be null.");
        if (!ModelState.IsValid) return BadRequest(ModelState);
        var budget = await service.UpdateAsync(budgetId, request, CurrentUser.Id);
        return Ok(budget, "Budget updated successfully");
    }

    [HttpDelete]
    [Route("{budgetId:guid}")]
    public async Task<ActionResult> Delete(Guid budgetId)
    {
        await service.DeleteAsync(budgetId, CurrentUser.Id);
        return Ok<object>(null, "Budget deleted successfully");
    }
}
