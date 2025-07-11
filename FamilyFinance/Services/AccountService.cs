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

public class AccountService(AppDbContext dbContext) : BaseService(dbContext)
{
    /// <summary>
    /// Gets a list of accounts for a user with optional filtering.
    /// </summary>
    /// <param name="userId"></param>
    /// <param name="filter"></param>
    /// <returns></returns>
    public async Task<Paginated<AccountListItem>> ListAsync(Guid userId, AccountListFilter filter)
    {
        var query = DbContext.Accounts.Where(x => x.UserId == userId);
        if (filter.IsActive != null){
            query = query.Where(a => (a.DeletedAt == null) == filter.IsActive);
        }
        if (!string.IsNullOrWhiteSpace(filter.SearchTerm))
        {
            var searchTerm = filter.SearchTerm.Trim().ToLower();
            query = query.Where(a => a.Name.ToLower().Contains(searchTerm) || a.Description.ToLower().Contains(searchTerm));
        }
        var totalCount = await query.CountAsync();
        var items = await query
            .OrderBy(a => a.Name)
            .Skip((filter.Page - 1) * filter.PageSize)
            .Take(filter.PageSize)
            .ToListAsync();

        return new Paginated<AccountListItem> {
            Items = items.Select(a => new AccountListItem(a)),
            TotalCount = totalCount,
            Page = filter.Page,
            PageSize = filter.PageSize,
        };
    }

    /// <summary>
    /// Gets a specific account by its ID.
    /// </summary>
    /// <param name="accountId"></param>
    /// <returns></returns>
    /// <exception cref="EntityNotFoundException"></exception>
    public async Task<AccountDto> Get(Guid userId, Guid accountId)
    {
        var item = await DbContext.Accounts
            .FirstOrDefaultAsync(a => a.UserId == userId && a.Id == accountId)
            ?? throw new EntityNotFoundException("Account not found");
        return new AccountDto(item);
    }

    /// <summary>
    /// Creates a new account for a user.
    /// </summary>
    /// <param name="request"></param>
    /// <param name="userId"></param>
    /// <returns></returns>
    public async Task<AccountDto> CreateAsync(Guid userId, AccountSaveRequest request, Guid currentUserId)
    {
        var now = DateTime.Now;
        var account = new Account {
            Name = request.Name,
            Description = request.Description,
            UserId = userId,
            CreatedAt = now,
            CreatedBy = currentUserId,
            UpdatedAt = now,
            UpdatedBy = currentUserId,
        };
        DbContext.Accounts.Add(account);
        await DbContext.SaveChangesAsync();

        return new AccountDto(account);
    }

    /// <summary>
    /// Updates an existing account for a user.
    /// </summary>
    /// <param name="accountId"></param>
    /// <param name="request"></param>
    /// <param name="currentUserId"></param>
    /// <returns></returns>
    /// <exception cref="EntityNotFoundException"></exception>
    public async Task<AccountDto> UpdateAsync(Guid userId, Guid accountId, AccountSaveRequest request, Guid currentUserId)
    {
        var account = await DbContext.Accounts
            .FirstOrDefaultAsync(a => a.Id == accountId && a.UserId == userId)
            ?? throw new EntityNotFoundException("Account not found");

        account.Name = request.Name;
        account.Description = request.Description;
        account.UpdatedAt = DateTime.Now;
        account.UpdatedBy = currentUserId;
        DbContext.Accounts.Update(account);
        await DbContext.SaveChangesAsync();
        return new AccountDto(account);
    }

    /// <summary>
    /// Delete an account for a user by marking it as deleted.
    /// </summary>
    /// <param name="accountId"></param>
    /// <param name="currentUserId"></param>
    /// <returns></returns>
    /// <exception cref="EntityNotFoundException"></exception>
    public async Task DeleteAsync(Guid userId, Guid accountId, Guid currentUserId)
    {
        var account = await DbContext.Accounts
            .FirstOrDefaultAsync(a => a.Id == accountId && a.UserId == userId && a.DeletedAt == null)
            ?? throw new EntityNotFoundException("Account not found");

        account.DeletedAt = DateTime.Now;
        account.DeletedBy = currentUserId;
        DbContext.Accounts.Update(account);
        await DbContext.SaveChangesAsync();
    }

    /// <summary>
    /// Restore a deleted account for a user.
    /// </summary>
    /// <param name="userId"></param>
    /// <param name="accountId"></param>
    /// <param name="currentUserId"></param>
    /// <returns></returns>
    /// <exception cref="EntityNotFoundException"></exception>
    public async Task<AccountDto> RestoreAsync(Guid userId, Guid accountId, Guid currentUserId)
    {
        var account = await DbContext.Accounts
            .FirstOrDefaultAsync(a => a.Id == accountId && a.UserId == userId && a.DeletedAt != null)
            ?? throw new EntityNotFoundException("Account not found");

        account.DeletedAt = null;
        account.DeletedBy = null;
        account.UpdatedAt = DateTime.Now;
        account.UpdatedBy = currentUserId;
        DbContext.Accounts.Update(account);
        await DbContext.SaveChangesAsync();

        return new(account);
    }
}
