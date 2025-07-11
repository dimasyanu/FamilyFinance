namespace FamilyFinance.Models.Requests;

public class UserSaveRequest
{
    public required string Name { get; set; }
    public required string Username { get; set; }
    public required string Password { get; set; }
    public required string RepeatPassword { get; set; }
}
