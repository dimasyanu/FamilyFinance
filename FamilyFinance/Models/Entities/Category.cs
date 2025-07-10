using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace FamilyFinance.Models.Entities;

[Table("categories")]
public class Category : BasicModel
{
    [Column("name")]
    [MaxLength(100)]
    [Required]
    public required string Name { get; set; }

    [Column("description")]
    [MaxLength(500)]
    public string Description { get; set; } = string.Empty;

    [Column("color")]
    [MaxLength(10)]
    [Required]
    public required string Color { get; set; }

    [Column("icon")]
    [MaxLength(50)]
    public string Icon { get; set; } = string.Empty;

    public virtual ICollection<Transaction> Transactions { get; set; } = [];
}
