using FamilyFinance.Models.Entities;

namespace FamilyFinance.Models.Responses.ListItems;

public class TransactionListItem
{
    public Guid Id { get; set; }
    public string Description { get; set; } = string.Empty;
    public decimal Amount { get; set; }
    public string TransactionDate { get; set; } = null!;
    public string TransactionTime { get; set; } = null!;
    public int TransactionType { get; set; }
    public string Category { get; set; } = null!;
    public string CategoryColor { get; set; } = null!;
    public int CategoryIcon { get; set; } = 0;
    public string Account { get; set; } = null!;
    public string AccountColor { get; set; } = null!;
    // public string? Notes { get; set; }

    public string CreatedAt { get; set; } = string.Empty;
    public string CreatedBy { get; set; } = string.Empty;
    public string UpdatedAt { get; set; } = string.Empty;
    public string UpdatedBy { get; set; } = string.Empty;

    public TransactionListItem()
    {
    }

    public TransactionListItem(Transaction transaction)
    {
        Id = transaction.Id;
        Description = transaction.Description;
        Amount = transaction.Amount;
        TransactionDate = transaction.Date.ToString("dd MMM yyyy");
        TransactionTime = transaction.Date.ToString("HH:mm");
        TransactionType = (int)transaction.TransactionType;
        // Category = new(transaction.Category ?? new());
        // Account = new(transaction.Account ?? new());
        Category = transaction.Category?.Name ?? "";
        CategoryColor = transaction.Category?.Color ?? "";
        CategoryIcon = transaction.Category?.Icon ?? 0;
        Account = transaction.Account?.Name ?? "";
        AccountColor = transaction.Account?.Color ?? "";

        CreatedAt = transaction.CreatedAt.ToString("dd MMM yyyy, HH:mm");
        CreatedBy = transaction.CreatedBy.ToString();
        UpdatedAt = transaction.UpdatedAt.ToString("dd MMM yyyy, HH:mm");
        UpdatedBy = transaction.UpdatedBy.ToString();
    }
}
