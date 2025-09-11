using FamilyFinance.Models.Entities;

namespace FamilyFinance.Models.Responses.ListItems;

public class BudgetListItem
{
    public int Id { get; set; }
    public int Month { get; set; }
    public int Year { get; set; }
    public decimal Amount { get; set; }
    public CategoryListItem Category { get; set; } = null!;
    public BudgetListItem()
    {
    }
    public BudgetListItem(Budget budget)
    {
        Id = budget.Id;
        Month = budget.StartDate.Month;
        Year = budget.EndDate.Year;
        Amount = budget.Amount;
        Category = new CategoryListItem(budget.Category);
    }
}
