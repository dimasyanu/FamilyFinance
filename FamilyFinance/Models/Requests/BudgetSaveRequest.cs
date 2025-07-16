using System.ComponentModel.DataAnnotations;

namespace FamilyFinance.Models.Requests;

public class BudgetSaveRequest
{
    public Guid? Id { get; set; }

    [Required]
    public Guid CategoryId { get; set; }

    [Required]
    public int Month { get; set; }

    [Required]
    public int Year { get; set; }

    [Required]
    public decimal Amount { get; set; }
}
