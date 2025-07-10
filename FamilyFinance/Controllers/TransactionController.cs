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
[Route("Api/Transactions")]
[Authorize]
public class TransactionController(TransactionService service) : BaseController
{
    private readonly TransactionService _service = service ?? throw new ArgumentNullException(nameof(service));

    [HttpGet]
    [Route("")]
    public async Task<ActionResult<Response<TransactionListItem>>> List([FromQuery]TransactionListFilter filter)
    {
        var results = await _service.ListAsync(filter);
        return Ok(results);
    }

    [HttpGet]
    [Route("{transactionId:guid}")]
    public async Task<ActionResult<TransactionDto>> Get(Guid transactionId)
    {
        var transaction = await _service.GetByIdAsync(transactionId);
        if (transaction == null) return NotFound("Transaction not found.");
        return Ok(transaction);
    }

    [HttpPost]
    [Route("")]
    public async Task<ActionResult<Response<TransactionDto>>> Create([FromBody] TransactionSaveRequest request)
    {
        if (request == null) return BadRequest("Request cannot be null.");
        if (!ModelState.IsValid) return BadRequest(ModelState);
        
        var user = await GetCurrentUser();
        request.SetCurrentUser(user.Id);

        var transaction = await _service.CreateAsync(request);
        return Ok(transaction, "Transaction created successfully");
    }

    [HttpPut]
    [Route("{transactionId:guid}")]
    public async Task<ActionResult<Response<TransactionDto>>> Update(Guid transactionId, [FromBody] TransactionSaveRequest request)
    {
        if (request == null) return BadRequest("Request cannot be null.");
        if (!ModelState.IsValid) return BadRequest(ModelState);
        
        var user = await GetCurrentUser();
        request.SetCurrentUser(user.Id);

        var transaction = await _service.UpdateAsync(transactionId, request);
        return Ok(transaction, "Transaction updated successfully");
    }

    [HttpDelete]
    [Route("{transactionId:guid}")]
    public async Task<ActionResult<Response<object>>> Delete(Guid transactionId)
    {
        await _service.DeleteAsync(transactionId);
        return Ok<object>(null, "Transaction deleted successfully");
    }
}
