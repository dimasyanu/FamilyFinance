using FamilyFinance.Models.Entities;

namespace FamilyFinance.Models.Dtos;

public class UserDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Username { get; set; } = string.Empty;
    public bool IsActive { get; set; }
    public string AvatarUrl { get; set; } = string.Empty;

    public UserDto()
    {
    }

    public UserDto(User user)
    {
        Id = user.Id;
        Name = user.Name;
        Username = user.Username;
        IsActive = user.DeletedAt == null;
        AvatarUrl = Path.Combine("/avatars/", user.Username + ".png");
    }
}
