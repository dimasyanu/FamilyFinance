namespace FamilyFinance.Models.Requests.ListFilters;

public class TransactionListFilter : BaseListFilter
{
    public decimal? MinAmount { get; set; }
    public decimal? MaxAmount { get; set; }
    public DateTime? MinDate { get; set; }
    public DateTime? MaxDate { get; set; }
    public IEnumerable<string>? UserIds { get; set; }
    public IEnumerable<string>? CategoryIds { get; set; }
    public string? SortBy { get; set; }
    public string? SortDirection { get; set; }
    public bool? IsActive { get; set; } = true;
}
