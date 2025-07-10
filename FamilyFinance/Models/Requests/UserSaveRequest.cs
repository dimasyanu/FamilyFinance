namespace FamilyFinance.Models.Requests;

public class UserSaveRequest
{
    public required string Name { get; set; }
    public required string Username { get; set; }
    public required string Password { get; set; }
    public required string RepeatPassword { get; set; }
    public Guid? UserId { get; private set; }
    public DateTime? Timestamp { get; private set; }

    public void SetCurrentUser(Guid userId)
    {
        UserId = userId;
        Timestamp = DateTime.Now;
    }
}
