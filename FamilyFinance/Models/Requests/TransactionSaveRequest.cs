using FamilyFinance.Models.Entities;

namespace FamilyFinance.Models.Requests;

public class TransactionSaveRequest
{
    public Guid? Id { get; set; }
    public string Description { get; set; } = string.Empty;
    public decimal Amount { get; set; }
    public TransactionType TransactionType { get; set; }
    public DateTime TransactionDate { get; set; }
    public Guid? CategoryId { get; set; }
    public Guid AccountId { get; set; }
}
