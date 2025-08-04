using FamilyFinance.Models.Entities;

namespace FamilyFinance.Models.Responses.ListItems;

public class BudgetListItem
{
    public Guid Id { get; set; }
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
    public decimal Amount { get; set; }
    public CategoryListItem Category { get; set; } = null!;
    public BudgetListItem()
    {
    }
    public BudgetListItem(Budget budget)
    {
        Id = budget.Id;
        StartDate = budget.StartDate;
        EndDate = budget.EndDate;
        Amount = budget.Amount;
        Category = new CategoryListItem(budget.Category);
    }
}
