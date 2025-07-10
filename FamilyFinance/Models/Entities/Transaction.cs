using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace FamilyFinance.Models.Entities;

[Table("transactions")]
public class Transaction : BaseModel
{
    [Column("user_id")]
    public required Guid UserId { get; set; }

    [Column("transaction_type")]
    [Required]
    [EnumDataType(typeof(TransactionType))]
    public TransactionType TransactionType { get; set; }

    [Column("amount")]
    [Required]
    public required decimal Amount { get; set; }

    [Column("date")]
    [Required]
    public required DateTime Date { get; set; }

    [Column("description")]
    [MaxLength(500)]
    public string Description { get; set; } = string.Empty;

    [Column("category_id")]
    public Guid? CategoryId { get; set; }

    [ForeignKey("UserId")]
    public virtual User? User { get; set; }

    [ForeignKey("CategoryId")]
    public virtual Category? Category { get; set; }
}

public enum TransactionType
{
    Expense = -1,
    None = 0,
    Income = 1,
}
