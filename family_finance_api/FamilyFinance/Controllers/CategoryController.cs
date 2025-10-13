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
    [Route("{categoryId:int}")]
    public async Task<ActionResult<CategoryListItem>> Get(int categoryId)
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

        var category = await _service.CreateAsync(request, CurrentUser.Id);
        return Created(category, "Category created successfully");
    }

    [HttpPatch]
    [Route("{categoryId:int}")]
    public async Task<ActionResult<Response<CategoryDto>>> Update(int categoryId, [FromBody] CategorySaveRequest request)
    {
        if (request == null) return BadRequest("Request cannot be null.");
        if (!ModelState.IsValid) return BadRequest(ModelState);

        var category = await _service.UpdateAsync(categoryId, request);
        return Ok(category, "Category updated successfully");
    }

    [HttpDelete]
    [Route("{categoryId:int}")]
    public async Task<ActionResult> Delete(int categoryId)
    {
        await _service.DeleteAsync(categoryId);
        return Ok("Category deleted successfully");
    }
}
