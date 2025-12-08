using FamilyFinance.Abstractions;
using FamilyFinance.Models.Dtos;
using FamilyFinance.Models.Entities;
using FamilyFinance.Services;
using FamilyFinance.Utils;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace FamilyFinance.Test;

public class BaseUnitTest : IDisposable
{
    protected readonly IServiceProvider ServiceProvider;

    public BaseUnitTest()
    {
        var serviceCollection = new ServiceCollection();
        serviceCollection.AddDbContext<AppDbContext>(opt => opt.UseInMemoryDatabase("TestDatabase"));
        serviceCollection.AddScoped<IUserService, UserService>();
        serviceCollection.AddScoped<AccountService>();
        ServiceProvider = serviceCollection.BuildServiceProvider();

        // Ensure the in-memory database is created and seeded
        using var serviceScope = ServiceProvider.CreateScope();
        var dbContext = serviceScope.ServiceProvider.GetRequiredService<AppDbContext>();
        dbContext.Database.EnsureCreated();
    }

    protected async Task<UserDto> GetSystemUser(IServiceScope scope)
    {
        var userService = GetService<IUserService>(scope);
        return await userService.GetUserByUsernameAsync("system");
    }

    protected AppDbContext GetDbContext(IServiceScope scope) => scope.ServiceProvider.GetRequiredService<AppDbContext>();

    protected T GetService<T>(IServiceScope scope) where T : notnull => scope.ServiceProvider.GetRequiredService<T>();

    public void Dispose()
    {
        using var serviceScope = ServiceProvider.CreateScope();
        var dbContext = serviceScope.ServiceProvider.GetRequiredService<AppDbContext>();
        dbContext.Database.EnsureDeleted();
    }
}
