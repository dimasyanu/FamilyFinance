namespace FamilyFinance.Models.Responses;

public class LoginResponse
{
    public required string Username { get; set; }
    public required string AccessToken { get; set; }
    public required string RefreshToken { get; set; }
    public required DateTime Expiration { get; set; }
}
