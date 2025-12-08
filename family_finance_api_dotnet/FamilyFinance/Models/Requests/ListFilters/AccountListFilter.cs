namespace FamilyFinance.Models.Requests.ListFilters;

public class AccountListFilter : BaseListFilter
{
    public bool? IsActive { get; set; } = true;
}
