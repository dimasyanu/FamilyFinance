using FamilyFinance.Models.Entities;

namespace FamilyFinance.Models.Responses.ListItems;

public class TransactionListItem
{
    public Guid Id { get; set; }
    public string Description { get; set; } = string.Empty;
    public decimal Amount { get; set; }
    public DateTime TransactionDate { get; set; }
    public Guid? CategoryId { get; set; }
    public Guid UserId { get; set; }
    public string? Notes { get; set; }

    public TransactionListItem()
    {
    }

    public TransactionListItem(Transaction transaction)
    {
        Id = transaction.Id;
        Description = transaction.Description;
        Amount = transaction.Amount;
        TransactionDate = transaction.Date;
        CategoryId = transaction.CategoryId;
        UserId = transaction.UserId;
    }
}
