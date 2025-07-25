using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace FamilyFinance.Models.Entities;

[Table("categories")]
public class Category : BasicModel
{
    [Column("name")]
    [MaxLength(100)]
    [Required]
    public string Name { get; set; } = string.Empty;

    [Column("description")]
    [MaxLength(500)]
    public string Description { get; set; } = string.Empty;

    [Column("color")]
    [MaxLength(10)]
    [Required]
    public string Color { get; set; } = string.Empty;

    [Column("icon")]
    [MaxLength(50)]
    public string Icon { get; set; } = string.Empty;

    public virtual ICollection<Transaction> Transactions { get; set; } = [];
}
