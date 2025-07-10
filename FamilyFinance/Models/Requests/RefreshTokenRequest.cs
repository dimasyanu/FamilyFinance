using System.ComponentModel.DataAnnotations;

namespace FamilyFinance.Models.Requests;

public class RefreshTokenRequest
{
    [Required]
    public string Username { get; set; } = string.Empty;

    [Required]
    public string RefreshToken { get; set; } = string.Empty;
}
