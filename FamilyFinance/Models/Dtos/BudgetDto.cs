using FamilyFinance.Models.Entities;

namespace FamilyFinance.Models.Dtos;

public class BudgetDto
{
    public Guid Id { get; set; }
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
    public decimal Amount { get; set; }
    public CategoryDto Category { get; set; } = null!;

    public BudgetDto() { }
    public BudgetDto(Budget budget)
    {
        Id = budget.Id;
        StartDate = budget.StartDate;
        EndDate = budget.EndDate;
        Amount = budget.Amount;
        Category = new CategoryDto(budget.Category);
    }
}
