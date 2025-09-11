using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace FamilyFinance.Models.Entities;

[Table("accounts")]
public class Account : BaseModel<int>
{
    [Column("name")]
    [MaxLength(100)]
    public string Name { get; set; } = string.Empty;

    [Column("description")]
    [MaxLength(256)]
    public string Description { get; set; } = string.Empty;

    [Column("color")]
    [MaxLength(7)]
    public string Color { get; set; } = string.Empty;

    [Column("balance")]
    public decimal Balance { get; set; }

    [Column("user_id")]
    public int UserId { get; set; }

    [ForeignKey("UserId")]
    public virtual User User { get; set; } = null!;

    public virtual ICollection<Transaction> Transactions { get; set; } = [];
}
