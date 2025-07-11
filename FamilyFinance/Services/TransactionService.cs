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

public class TransactionService(AppDbContext dbContext) : BaseService(dbContext)
{
    /// <summary>
    /// Gets a paginated list of transactions based on the provided filter.    /// </summary>
    /// <param name="filter"></param>
    /// <returns></returns>
    public async Task<Paginated<TransactionListItem>> ListAsync(TransactionListFilter filter)
    {
        var query = DbContext.Transactions.AsQueryable();
        var totalCount = await query.CountAsync();
        var items = await query
            .Skip(filter.Page * filter.PageSize)
            .Take(filter.PageSize)
            .ToListAsync();

        return new Paginated<TransactionListItem> {
            Items = items.Select(x => new TransactionListItem(x)),
            Page = filter.Page,
            PageSize = filter.PageSize,
            TotalCount = totalCount,
        };
    }

    /// <summary>
    /// Gets a transaction by its ID.
    /// </summary>
    /// <param name="transactionId"></param>
    /// <returns></returns>
    /// <exception cref="EntityNotFoundException"></exception>
    public async Task<TransactionDto> GetByIdAsync(Guid transactionId)
    {
        var transaction = await DbContext.Transactions.FirstOrDefaultAsync(x => x.Id == transactionId)
            ?? throw new EntityNotFoundException("Transaction is not found");
        return new(transaction);
    }

    /// <summary>
    /// Creates a new transaction.
    /// </summary>
    /// <param name="request"></param>
    /// <returns></returns>
    /// <exception cref="UnauthorizedAccessException"></exception>
    public async Task<TransactionDto> CreateAsync(TransactionSaveRequest request, Guid currentUserId)
    {
        var now = DateTime.Now;
        var transaction = new Transaction {
            Description = request.Description,
            Amount = request.Amount,
            Date = request.TransactionDate,
            CategoryId = request.CategoryId,
            AccountId = request.AccountId,
            TransactionType = request.TransactionType,
            CreatedAt = now,
            CreatedBy = currentUserId,
            UpdatedAt = now,
            UpdatedBy = currentUserId,
        };
        DbContext.Transactions.Add(transaction);
        await DbContext.SaveChangesAsync();
        return new(transaction);
    }

    /// <summary>
    /// Updates an existing transaction.
    /// </summary>
    /// <param name="transactionId"></param>
    /// <param name="request"></param>
    /// <returns></returns>
    /// <exception cref="UnauthorizedAccessException"></exception>
    /// <exception cref="EntityNotFoundException"></exception>
    public async Task<TransactionDto> UpdateAsync(Guid transactionId, TransactionSaveRequest request, Guid currentUserId)
    {
        var transaction = await DbContext.Transactions.FirstOrDefaultAsync(x => x.Id == transactionId)
            ?? throw new EntityNotFoundException("Transaction is not found");

        if (transaction.Description != request.Description) {
            transaction.Description = request.Description;
        }
        if (transaction.AccountId != request.AccountId) {
            transaction.AccountId = request.AccountId;
        }
        if (transaction.Amount != request.Amount) {
            transaction.Amount = request.Amount;
        }
        if (transaction.Date != request.TransactionDate) {
            transaction.Date = request.TransactionDate;
        }
        if (transaction.CategoryId != request.CategoryId) {
            transaction.CategoryId = request.CategoryId;
        }
        if (transaction.TransactionType != request.TransactionType) {
            transaction.TransactionType = request.TransactionType;
        }

        transaction.UpdatedAt = DateTime.Now;
        transaction.UpdatedBy = currentUserId;

        DbContext.Transactions.Update(transaction);
        await DbContext.SaveChangesAsync();
        return new(transaction);
    }

    /// <summary>
    /// Deletes a transaction by its ID.
    /// </summary>
    /// <param name="transactionId"></param>
    /// <returns></returns>
    /// <exception cref="EntityNotFoundException"></exception>
    public async Task DeleteAsync(Guid transactionId)
    {
        var transaction = await DbContext.Transactions.FirstOrDefaultAsync(x => x.Id == transactionId)
            ?? throw new EntityNotFoundException("Transaction is not found");

        DbContext.Transactions.Remove(transaction);
        await DbContext.SaveChangesAsync();
    }

    /// <summary>
    /// Restores a deleted transaction by its ID.
    /// </summary>
    /// <param name="transactionId"></param>
    /// <param name="currentUserId"></param>
    /// <returns></returns>
    /// <exception cref="EntityNotFoundException"></exception>
    public async Task<TransactionDto> RestoreAsync(Guid transactionId, Guid currentUserId)
    {
        var transaction = await DbContext.Transactions.FirstOrDefaultAsync(x => x.Id == transactionId)
            ?? throw new EntityNotFoundException("Transaction is not found");
        transaction.DeletedAt = null;
        transaction.DeletedBy = null;
        transaction.UpdatedAt = DateTime.Now;
        transaction.UpdatedBy = currentUserId;
        DbContext.Transactions.Update(transaction);
        await DbContext.SaveChangesAsync();
        return new(transaction);
    }
}