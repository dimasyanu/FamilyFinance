namespace FamilyFinance.Models.Responses;

public class LoginResponse
{
    public string Username { get; set; } = string.Empty;
    public Guid UserId { get; set; }
    public string AccessToken { get; set; } = string.Empty;
    public string RefreshToken { get; set; } = string.Empty;
    public DateTime Expiration { get; set; }
}
