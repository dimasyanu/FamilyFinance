using FamilyFinance.Models.Dtos;
using FamilyFinance.Models.Requests;
using FamilyFinance.Services;
using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace FamilyFinance.Test.AccountTests;

public class AccountCrudTest : BaseUnitTest
{
    [Fact]
    public async Task Account_Create_Success()
    {
        UserDto user;
        var accountPayload = new AccountSaveRequest {
            Name = "Test Account",
            Color = "#FF5733",
            Description = "Test account for unit testing",
        };
        using (var scope = ServiceProvider.CreateScope()) {
            user = await GetSystemUser(scope);
            var accountService = GetService<AccountService>(scope);
            Func<Task> action = async () => await accountService.CreateAsync(
                user.Id,
                accountPayload,
                user.Id
            );
            await action.Should().NotThrowAsync();

            await using (var dbContext = GetDbContext(scope))
            {
                var createdAccount = await dbContext.Accounts.FirstOrDefaultAsync(a => a.Name == "Test Account");
                createdAccount.Should().NotBeNull();
                createdAccount.Name.Should().Be(accountPayload.Name);
                createdAccount.Color.Should().Be(accountPayload.Color);
                createdAccount.Description.Should().Be(accountPayload.Description);
                createdAccount.Balance.Should().Be(0.0M);
                createdAccount.DeletedAt.Should().BeNull();
                createdAccount.DeletedBy.Should().BeNull();
            }
        }

        using (var scope = ServiceProvider.CreateScope())
        {
            var accountService = GetService<AccountService>(scope);
            var accounts = await accountService.ListAsync(user.Id, new() { Page = 1, PageSize = 10 });
            accounts.Should().NotBeNull();
            accounts.Items.Should().NotBeNullOrEmpty().And.HaveCount(1);
            accounts.Items.First().Name.Should().Be(accountPayload.Name);
            accounts.Items.First().Color.Should().Be(accountPayload.Color);
            accounts.Items.First().Description.Should().Be(accountPayload.Description);
            accounts.Items.First().Balance.Should().Be(0.0M);
            accounts.Items.First().IsActive.Should().BeTrue();
        }
    }
}
