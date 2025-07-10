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
    public async Task<TransactionDto> CreateAsync(TransactionSaveRequest request)
    {
        var editorId = request.EditorId ?? throw new UnauthorizedAccessException();
        var transaction = new Transaction {
            Description = request.Description,
            Amount = request.Amount,
            Date = request.TransactionDate,
            CategoryId = request.CategoryId,
            UserId = request.UserId,
            TransactionType = request.TransactionType,
            CreatedAt = request.Timestamp,
            CreatedBy = editorId,
            UpdatedAt = request.Timestamp,
            UpdatedBy = editorId,
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
    public async Task<TransactionDto> UpdateAsync(Guid transactionId, TransactionSaveRequest request)
    {
        var editorId = request.EditorId ?? throw new UnauthorizedAccessException();
        var transaction = await DbContext.Transactions.FirstOrDefaultAsync(x => x.Id == transactionId)
            ?? throw new EntityNotFoundException("Transaction is not found");

        if (transaction.Description != request.Description) {
            transaction.Description = request.Description;
        }
        if (transaction.UserId != request.UserId) {
            transaction.UserId = request.UserId;
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

        transaction.UpdatedAt = request.Timestamp;
        transaction.UpdatedBy = editorId;

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
}