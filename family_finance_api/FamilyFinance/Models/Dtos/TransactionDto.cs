using FamilyFinance.Models.Entities;

namespace FamilyFinance.Models.Dtos;

public class TransactionDto
{
    public Guid Id { get; set; }
    public string Description { get; set; } = string.Empty;
    public decimal Amount { get; set; }
    public string TransactionDate { get; set; } = null!;
    public string TransactionTime { get; set; } = null!;
    public int TransactionType { get; set; }
    public AccountDto Account { get; set; } = null!;
    public CategoryDto? Category { get; set; }

    public string CreatedAt { get; set; } = string.Empty;
    public string CreatedBy { get; set; } = string.Empty;
    public string UpdatedAt { get; set; } = string.Empty;
    public string UpdatedBy { get; set; } = string.Empty;

    public TransactionDto()
    {
    }

    public TransactionDto(Transaction transaction)
    {
        Id = transaction.Id;
        Description = transaction.Description;
        Amount = transaction.Amount;
        TransactionDate = transaction.Date.ToString("yyyy-MM-dd");
        TransactionTime = transaction.Date.ToString("HH:mm");
        TransactionType = (int)transaction.TransactionType;
        if (transaction.Category != null) {
            Category = new(transaction.Category);
        }
        Account = new(transaction.Account!);

        CreatedAt = transaction.CreatedAt.ToString("dd MMM yyyy, HH:mm");
        CreatedBy = transaction.CreatedBy.ToString();
        UpdatedAt = transaction.UpdatedAt.ToString("dd MMM yyyy, HH:mm");
        UpdatedBy = transaction.UpdatedBy.ToString();
    }
}
