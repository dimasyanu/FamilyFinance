using System.ComponentModel.DataAnnotations;

namespace FamilyFinance.Models.Requests;

public class UserSaveRequest
{

    [Required]
    public string Name { get; set; } = string.Empty;
    
    [Required]
    public string Username { get; set; } = string.Empty;
    
    [Required]
    public string Password { get; set; } = string.Empty;
    
    [Required]
    public string RepeatPassword { get; set; } = string.Empty;
}
