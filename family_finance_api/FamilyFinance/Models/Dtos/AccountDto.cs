using FamilyFinance.Models.Entities;

namespace FamilyFinance.Models.Dtos;

public class AccountDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string Color { get; set; } = string.Empty;

    public AccountDto()
    {
    }

    public AccountDto(Account account)
    {
        Id = account.Id;
        Name = account.Name;
        Description = account.Description;
        Color = account.Color;
    }
}
