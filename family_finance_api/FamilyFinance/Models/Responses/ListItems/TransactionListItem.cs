using FamilyFinance.Models.Entities;

namespace FamilyFinance.Models.Responses.ListItems;

public class TransactionListItem
{
    public Guid Id { get; set; }
    public string Description { get; set; } = string.Empty;
    public decimal Amount { get; set; }
    public DateTime TransactionDate { get; set; }
    public CategoryListItem Category { get; set; } = null!;
    public AccountListItem Account { get; set; } = null!;
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
        Category = new(transaction.Category ?? new());
        Account = new(transaction.Account ?? new());
    }
}
