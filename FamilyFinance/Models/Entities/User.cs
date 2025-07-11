using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace FamilyFinance.Models.Entities;

[Table("users")]
public class User : BaseModel
{
    [Column("name")]
    [MaxLength(100)]
    [Required]
    public required string Name { get; set; }

    [Column("username")]
    [MaxLength(100)]
    [Required]
    public required string Username { get; set; }

    [Column("password_hash")]
    [MaxLength(255)]
    [Required]
    public required string PasswordHash { get; set; }

    [Column("refresh_token")]
    [MaxLength(255)]
    public string RefreshToken { get; set; } = string.Empty;

    public virtual ICollection<Account> Accounts { get; set; } = [];
}
