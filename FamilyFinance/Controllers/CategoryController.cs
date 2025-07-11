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
[Route("Api/Categories")]
public class CategoryController(CategoryService service) : BaseController
{
    private readonly CategoryService _service = service ?? throw new ArgumentNullException(nameof(service));

    [HttpGet]
    [Route("")]
    public async Task<ActionResult<Response<CategoryListItem>>> List([FromQuery]CategoryListFilter filter)
    {
        var results = await _service.ListAsync(filter);
        return Ok(results);
    }

    [HttpGet]
    [Route("{categoryId:guid}")]
    public async Task<ActionResult<CategoryListItem>> Get(Guid categoryId)
    {
        var category = await _service.GetByIdAsync(categoryId);
        if (category == null) return NotFound("Category not found.");
        return Ok(category);
    }

    [HttpPost]
    [Route("")]
    public async Task<ActionResult<Response<CategoryDto>>> Create([FromBody] CategorySaveRequest request)
    {
        if (request == null) return BadRequest("Request cannot be null.");
        if (!ModelState.IsValid) return BadRequest(ModelState);

        var currentUser = await GetCurrentUser();

        var category = await _service.CreateAsync(request, currentUser.Id);
        return Ok(category, "Category created successfully");
    }

    [HttpPut]
    [Route("{categoryId:guid}")]
    public async Task<ActionResult<Response<CategoryDto>>> Update(Guid categoryId, [FromBody] CategorySaveRequest request)
    {
        if (request == null) return BadRequest("Request cannot be null.");
        if (!ModelState.IsValid) return BadRequest(ModelState);

        var category = await _service.UpdateAsync(categoryId, request);
        return Ok(category, "Category updated successfully");
    }

    [HttpDelete]
    [Route("{categoryId:guid}")]
    public async Task<ActionResult> Delete(Guid categoryId)
    {
        await _service.DeleteAsync(categoryId);
        return Ok("Category deleted successfully");
    }
}
