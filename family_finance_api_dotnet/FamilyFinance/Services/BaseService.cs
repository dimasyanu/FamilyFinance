using FamilyFinance.Utils;

namespace FamilyFinance.Services;

public abstract class BaseService(AppDbContext dbContext)
{
    protected readonly AppDbContext DbContext = dbContext;
}
