using FamilyFinance.Models.Entities;

namespace FamilyFinance.Models.Responses.ListItems;

public class UserListItem
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Username { get; set; } = string.Empty;
    public bool IsActive { get; set; }

    public UserListItem()
    {
    }

    public UserListItem(User user)
    {
        Id = user.Id;
        Name = user.Name;
        Username = user.Username;
        IsActive = user.DeletedAt == null;
    }
}
