using FamilyFinance.Utils;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace FamilyFinance.Test;

public class BaseUnitTest
{
    protected readonly IServiceProvider _serviceProvider;

    public BaseUnitTest()
    {
        var serviceCollection = new ServiceCollection();
        serviceCollection.AddDbContext<AppDbContext>(opt => opt.UseInMemoryDatabase("TestDatabase"));
        _serviceProvider = serviceCollection.BuildServiceProvider();
    }

    protected AppDbContext GetDbContext() => _serviceProvider.GetRequiredService<AppDbContext>();

    protected T GetService<T>() where T : notnull => _serviceProvider.GetRequiredService<T>();
}
