using FamilyFinance.Models.Entities;

namespace FamilyFinance.Models.Responses.ListItems;

public class AccountListItem
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public decimal Balance { get; set; }
    public DateTime CreatedAt { get; set; }
    public Guid CreatedBy { get; set; }
    public DateTime? UpdatedAt { get; set; }
    public Guid? UpdatedBy { get; set; }
    public bool IsActive { get; set; }

    public AccountListItem()
    {
    }

    public AccountListItem(Account account)
    {
        Id = account.Id;
        Name = account.Name;
        Description = account.Description;
        Balance = account.Balance;
        CreatedAt = account.CreatedAt;
        CreatedBy = account.CreatedBy;
        UpdatedAt = account.UpdatedAt;
        UpdatedBy = account.UpdatedBy;
        IsActive = account.DeletedAt != null;
    }
}
