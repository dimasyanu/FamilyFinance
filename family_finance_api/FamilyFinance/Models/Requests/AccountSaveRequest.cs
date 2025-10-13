using System.ComponentModel.DataAnnotations;

namespace FamilyFinance.Models.Requests;

public class AccountSaveRequest
{
    [Required]
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string Color { get; set; } = string.Empty;
}
