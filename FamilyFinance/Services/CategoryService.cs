using FamilyFinance.Exceptions;
using FamilyFinance.Models.Dtos;
using FamilyFinance.Models.Entities;
using FamilyFinance.Models.Requests;
using FamilyFinance.Models.Requests.ListFilters;
using FamilyFinance.Models.Responses;
using FamilyFinance.Models.Responses.ListItems;
using FamilyFinance.Utils;
using Microsoft.EntityFrameworkCore;

namespace FamilyFinance.Services;

public class CategoryService(AppDbContext dbContext) : BaseService(dbContext)
{
    /// <summary>
    /// Get a list of categories with pagination and optional search filtering.
    /// </summary>
    /// <param name="filter"></param>
    /// <returns></returns>
    public async Task<Paginated<CategoryListItem>> ListAsync(CategoryListFilter filter)
    {
        var query = DbContext.Categories.AsQueryable();
        if (!string.IsNullOrEmpty(filter.SearchTerm))
        {
            var keyword = filter.SearchTerm.ToLower();
            query = query.Where(c => c.Name.ToLower().Contains(keyword) || c.Description.ToLower().Contains(keyword) || c.Color.ToLower().Contains(keyword));
        }

        var totalCount = await query.CountAsync();
        var items = await query
            .OrderBy(c => c.Name)
            .Skip((filter.Page - 1) * filter.PageSize)
            .Take(filter.PageSize)
            .Select(c => new CategoryListItem(c))
            .ToListAsync();

        return new Paginated<CategoryListItem> {
            Items = items,
            TotalCount = totalCount,
            Page = filter.Page,
            PageSize = filter.PageSize
        };
    }

    /// <summary>
    /// Get a category by its ID.
    /// </summary>
    /// <param name="id"></param>
    /// <returns></returns>
    public async Task<CategoryDto?> GetByIdAsync(Guid id)
    {
        var category = await DbContext.Categories
            .FirstOrDefaultAsync(c => c.Id == id);
        return category != null ? new CategoryDto(category) : null;
    }

    /// <summary>
    /// Create a new category.
    /// </summary>
    /// <param name="request"></param>
    /// <returns></returns>
    public async Task<CategoryDto> CreateAsync(CategorySaveRequest request)
    {
        var newCategory = new Category {
            Name = request.Name,
            Description = request.Description,
            Color = request.Color,
            CreatedAt = request.Timestamp ?? DateTime.Now,
            CreatedBy = request.UserId ?? throw new UnauthorizedAccessException(),
        };
        await DbContext.Categories.AddAsync(newCategory);
        await DbContext.SaveChangesAsync();
        return new CategoryDto(newCategory);
    }

    /// <summary>
    /// Update an existing category by its ID.
    /// </summary>
    /// <param name="id"></param>
    /// <param name="request"></param>
    /// <returns></returns>
    /// <exception cref="EntityNotFoundException"></exception>
    public async Task<CategoryDto> UpdateAsync(Guid id, CategorySaveRequest request)
    {
        var category = await DbContext.Categories.FindAsync(id)
            ?? throw new EntityNotFoundException($"Category with ID {id} not found.");

        category.Name = request.Name;
        category.Description = request.Description;
        category.Color = request.Color;
        DbContext.Categories.Update(category);
        await DbContext.SaveChangesAsync();
        return new CategoryDto(category);
    }

    /// <summary>
    /// Delete a category by its ID.
    /// </summary>
    /// <param name="id"></param>
    /// <returns></returns>
    /// <exception cref="EntityNotFoundException"></exception>
    public async Task DeleteAsync(Guid id)
    {
        var category = await DbContext.Categories.FindAsync(id)
            ?? throw new EntityNotFoundException($"Category with ID {id} not found.");
        DbContext.Categories.Remove(category);
        await DbContext.SaveChangesAsync();
    }
}
