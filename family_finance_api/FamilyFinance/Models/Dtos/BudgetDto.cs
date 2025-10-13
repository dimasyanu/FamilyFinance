using FamilyFinance.Models.Entities;

namespace FamilyFinance.Models.Dtos;

public class BudgetDto
{
    public int Id { get; set; }
    public int Month { get; set; }
    public int Year { get; set; }
    public decimal Amount { get; set; }
    public CategoryDto Category { get; set; } = null!;

    public BudgetDto() { }
    public BudgetDto(Budget budget)
    {
        Id = budget.Id;
        Month = budget.StartDate.Month;
        Year = budget.StartDate.Year;
        Amount = budget.Amount;
        Category = new CategoryDto(budget.Category);
    }
}
