using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace FamilyFinance.Models.Entities;

public class BaseModel<TId> : BasicModel<TId>
{

    [Column("updated_at")]
    [Required]
    public DateTime UpdatedAt { get; set; }

    [Column("updated_by")]
    [Required]
    public int UpdatedBy { get; set; }

    [Column("deleted_at")]
    public DateTime? DeletedAt { get; set; }

    [Column("deleted_by")]
    public int? DeletedBy { get; set; }
}

public class BasicModel<TId>
{
    [Key]
    [Column("id")]
    [Required]
    public TId Id { get; set; } = default!;

    [Column("created_at")]
    [Required]
    public DateTime CreatedAt { get; set; }

    [Column("created_by")]
    [Required]
    public int CreatedBy { get; set; }
}
