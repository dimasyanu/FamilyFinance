using System.ComponentModel.DataAnnotations;

namespace FamilyFinance.Models.Requests;

public class LoginRequest
{
    [Required]
    public required string Username { get; set; }

    [Required]
    public required string Password { get; set; }
}
