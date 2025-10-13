using FamilyFinance.Models.Entities;

namespace FamilyFinance.Models.Requests;

public class TransactionSaveRequest
{
    public string Description { get; set; } = string.Empty;
    public decimal Amount { get; set; }
    public TransactionType TransactionType { get; set; }
    public DateTime TransactionDate { get; set; }
    public int? CategoryId { get; set; }
    public int AccountId { get; set; }
}
