namespace FamilyFinance.Models.Requests.ListFilters;

public class BaseListFilter
{
    public string? SearchTerm { get; set; }
    public int Page { get; set; } = 1;
    public int PageSize { get; set; } = 25;
}
