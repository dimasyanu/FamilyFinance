using System.ComponentModel.DataAnnotations;

namespace FamilyFinance.Models.Requests;

public class CategorySaveRequest
{
    [Required]
    public string Name { get; set; } = string.Empty;

    public string Description { get; set; } = string.Empty;

    [Required]
    public string Color { get; set; } = string.Empty;
    public Guid? UserId { get; private set; } = null;
    public DateTime? Timestamp { get; private set; } = null;

    public void SetCurrentUser(Guid userId)
    {
        UserId = userId;
        Timestamp = DateTime.Now;
    }
}
