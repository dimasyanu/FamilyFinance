using FamilyFinance.Models.Entities;

namespace FamilyFinance.Models.Dtos;

public class TransactionDto
{
    public Guid Id { get; set; }
    public string Description { get; set; } = string.Empty;
    public decimal Amount { get; set; }
    public DateTime TransactionDate { get; set; }
    public CategoryDto? Category { get; set; }
    public Guid AccountId { get; set; }

    public TransactionDto()
    {
    }

    public TransactionDto(Transaction transaction)
    {
        Id = transaction.Id;
        Description = transaction.Description;
        Amount = transaction.Amount;
        TransactionDate = transaction.Date;
        if (transaction.Category != null) {
            Category = new(transaction.Category);
        }
        AccountId = transaction.AccountId;
    }
}
