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

public class BudgetService(AppDbContext dbContext) : BaseService(dbContext)
{
    /// <summary>
    /// Get a list of categories with pagination and optional search filtering.
    /// </summary>
    /// <param name="filter"></param>
    /// <returns></returns>
    public async Task<Paginated<BudgetListItem>> ListAsync(BudgetListFilter filter)
    {
        var query = DbContext.Budgets.AsQueryable();
        if (filter.Month != null) {
            query = query.Where(b => b.StartDate.Month == filter.Month);
        }

        if (filter.Year != null) {
            query = query.Where(b => b.StartDate.Year == filter.Year);
        }

        if (filter.CategoryId != null) {
            query = query.Where(b => b.CategoryId == filter.CategoryId);
        }

        if (filter.Active ?? true) {
            query = query.Where(b => b.DeletedAt == null);
        }

        var totalCount = await query.CountAsync();
        var items = await query
            .OrderBy(c => c.StartDate)
            .Skip((filter.Page - 1) * filter.PageSize)
            .Take(filter.PageSize)
            .Include(x => x.Category)
            .Select(c => new BudgetListItem(c))
            .ToListAsync();

        return new Paginated<BudgetListItem> {
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
    public async Task<BudgetDto?> GetByIdAsync(Guid id)
    {
        var budget = await DbContext.Budgets.Where(c => c.Id == id)
            .Include(x => x.Category)
            .FirstOrDefaultAsync();
        return budget != null ? new BudgetDto(budget) : null;
    }

    /// <summary>
    /// Create a new category.
    /// </summary>
    /// <param name="request"></param>
    /// <returns></returns>
    public async Task<BudgetDto> CreateAsync(BudgetSaveRequest request, Guid currentUserId)
    {
        var now = DateTime.Now;
        var sDate = DateTime.Parse($"{request.Year}-{request.Month}-1");
        var eDate = new DateTime(sDate.Year, sDate.Month, DateTime.DaysInMonth(sDate.Year, sDate.Month), 23, 59, 59);
        var newBudget = new Budget {
            CategoryId = request.CategoryId,
            StartDate = sDate,
            EndDate = eDate,
            Amount = request.Amount,
            CreatedAt = now,
            CreatedBy = currentUserId,
            UpdatedAt = now,
            UpdatedBy = currentUserId,
        };
        await DbContext.Budgets.AddAsync(newBudget);
        await DbContext.SaveChangesAsync();
        return await GetByIdAsync(newBudget.Id) 
               ?? throw new InvalidOperationException("Failed to retrieve the newly created budget.");
    }

    /// <summary>
    /// Update an existing category by its ID.
    /// </summary>
    /// <param name="id"></param>
    /// <param name="request"></param>
    /// <returns></returns>
    /// <exception cref="EntityNotFoundException"></exception>
    public async Task<BudgetDto> UpdateAsync(Guid id, BudgetSaveRequest request, Guid currentUserId)
    {
        var budget = await DbContext.Budgets.FindAsync(id)
            ?? throw new EntityNotFoundException($"Category with ID {id} not found.");

        var now = DateTime.Now;
        var sDate = DateTime.Parse($"{request.Year}-{request.Month}-1");
        var eDate = new DateTime(sDate.Year, sDate.Month, DateTime.DaysInMonth(sDate.Year, sDate.Month), 23, 59, 59);

        budget.CategoryId = request.CategoryId;
        budget.StartDate = sDate;
        budget.EndDate = eDate;
        budget.Amount = request.Amount;
        budget.UpdatedAt = now;
        budget.UpdatedBy = currentUserId;

        DbContext.Budgets.Update(budget);
        await DbContext.SaveChangesAsync();
        return new BudgetDto(budget);
    }

    /// <summary>
    /// Delete a category by its ID.
    /// </summary>
    /// <param name="id"></param>
    /// <returns></returns>
    /// <exception cref="EntityNotFoundException"></exception>
    public async Task DeleteAsync(Guid id, Guid currentUserId)
    {
        var budget = await DbContext.Budgets.FindAsync(id)
            ?? throw new EntityNotFoundException($"Category with ID {id} not found.");

        budget.DeletedAt = DateTime.Now;
        budget.DeletedBy = currentUserId;

        DbContext.Budgets.Update(budget);
        await DbContext.SaveChangesAsync();
    }
}
