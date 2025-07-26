using FamilyFinance.Models.Entities;

namespace FamilyFinance.Models.Responses.ListItems;

public class AccountListItem
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Color { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public decimal Balance { get; set; }
    public String CreatedAt { get; set; }
    public Guid CreatedBy { get; set; }
    public String? UpdatedAt { get; set; }
    public Guid? UpdatedBy { get; set; }
    public bool IsActive { get; set; }

    public AccountListItem()
    {
    }

    public AccountListItem(Account account)
    {
        Id = account.Id;
        Name = account.Name;
        Color = account.Color;
        Description = account.Description;
        Balance = account.Balance;
        CreatedAt = account.CreatedAt.ToString("dd-MMM-yyyy HH:mm");
        CreatedBy = account.CreatedBy;
        UpdatedAt = account.UpdatedAt.ToString("dd-MMM-yyyy HH:mm");
        UpdatedBy = account.UpdatedBy;
        IsActive = account.DeletedAt == null;
    }
}
