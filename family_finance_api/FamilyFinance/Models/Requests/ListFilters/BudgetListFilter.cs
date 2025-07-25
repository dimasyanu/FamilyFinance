namespace FamilyFinance.Models.Requests.ListFilters;

public class BudgetListFilter : BaseListFilter
{
    public int? Month { get; set; } = null;
    public int? Year { get; set; } = null;
    public Guid? CategoryId { get; set; }
}
