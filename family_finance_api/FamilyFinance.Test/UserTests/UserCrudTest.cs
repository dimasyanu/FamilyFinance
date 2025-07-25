using FamilyFinance.Abstractions;
using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace FamilyFinance.Test.UserTests;

public class UserCrudTest : BaseUnitTest
{
    [Fact]
    public async Task User_SystemUser_Exists()
    {
        using (var scope = ServiceProvider.CreateScope()) {
            await using var dbContext = GetDbContext(scope);
            var dbUsers = await dbContext.Users.ToListAsync();
            dbUsers.Should().NotBeNull();
            dbUsers.Should().NotBeEmpty().And.ContainSingle(u => u.Username == "system");
        }

        using (var scope = ServiceProvider.CreateScope()) {
            var userService = GetService<IUserService>(scope);
            var systemUser = await userService.GetUserByUsernameAsync("system");
            systemUser.Should().NotBeNull();
            systemUser.Username.Should().Be("system");
        }
    }

    [Fact]
    public async Task User_Create_Success()
    {
        using var scope = ServiceProvider.CreateScope();
        var userService = GetService<IUserService>(scope);
        var users = await userService.ListAsync(new() { Page = 1, PageSize = 10 });
        var systemUser = await userService.GetUserByUsernameAsync("system");
        Func<Task> action = async () => await userService.CreateUserAsync(new() {
            Username = "testuser",
            Password = "TestPassword123",
            Name = "User",
            RepeatPassword = "TestPassword123",
        }, systemUser.Id);
        await action.Should().NotThrowAsync();

        await using (var dbContext = GetDbContext(scope)) {
            var createdUser = await dbContext.Users.FirstOrDefaultAsync(u => u.Username == "testuser");
            createdUser.Should().NotBeNull();
            createdUser.Name.Should().Be("User");
        }
    }
}
