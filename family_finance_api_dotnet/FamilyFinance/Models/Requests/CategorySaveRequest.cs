using System.ComponentModel.DataAnnotations;

namespace FamilyFinance.Models.Requests;

public class CategorySaveRequest
{
    [Required]
    public string Name { get; set; } = string.Empty;

    public string Description { get; set; } = string.Empty;

    [Required]
    public int Icon { get; set; } = 0;

    [Required]
    public string Color { get; set; } = string.Empty;
}
