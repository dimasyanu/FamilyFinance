using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace FamilyFinance.Models.Entities;

public class BaseModel : BasicModel
{

    [Column("updated_at")]
    [Required]
    public DateTime UpdatedAt { get; set; }

    [Column("updated_by")]
    [Required]
    public Guid UpdatedBy { get; set; }

    [Column("deleted_at")]
    public DateTime? DeletedAt { get; set; }

    [Column("deleted_by")]
    public Guid? DeletedBy { get; set; }
}

public class BasicModel
{
    [Key]
    [Column("id")]
    [Required]
    public Guid Id { get; set; }

    [Column("created_at")]
    [Required]
    public DateTime CreatedAt { get; set; }

    [Column("created_by")]
    [Required]
    public Guid CreatedBy { get; set; }
}
