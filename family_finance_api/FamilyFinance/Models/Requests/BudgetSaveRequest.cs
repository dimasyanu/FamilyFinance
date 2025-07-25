using System.ComponentModel.DataAnnotations;

namespace FamilyFinance.Models.Requests;

public class BudgetSaveRequest
{
    [Required]
    public Guid CategoryId { get; set; }

    [Required]
    public int Month { get; set; }

    [Required]
    public int Year { get; set; }

    [Required]
    public decimal Amount { get; set; }
}
