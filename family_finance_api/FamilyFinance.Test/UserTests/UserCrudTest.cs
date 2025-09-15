using FamilyFinance.Abstractions;
using FluentAssertions;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace FamilyFinance.Test.UserTests;

public class UserCrudTest : BaseUnitTest
{
    [Fact]
    public async Task User_SystemUser_Exists()
    {
        using (var scope = ServiceProvider.CreateScope())
        {
            await using var dbContext = GetDbContext(scope);
            var dbUsers = await dbContext.Users.ToListAsync();
            dbUsers.Should().NotBeNull();
            dbUsers.Should().NotBeEmpty().And.ContainSingle(u => u.Username == "system");
        }

        using (var scope = ServiceProvider.CreateScope())
        {
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
        Func<Task> action = async () => await userService.CreateUserAsync(new()
        {
            Username = "testuser",
            Password = "TestPassword123",
            Name = "User",
            RepeatPassword = "TestPassword123",
        }, systemUser.Id);
        await action.Should().NotThrowAsync();

        await using (var dbContext = GetDbContext(scope))
        {
            var createdUser = await dbContext.Users.FirstOrDefaultAsync(u => u.Username == "testuser");
            createdUser.Should().NotBeNull();
            createdUser.Name.Should().Be("User");
        }
    }

    [Fact]
    public async Task User_ChangeAvatarPicture_Success()
    {
        using var scope = ServiceProvider.CreateScope();
        var userService = GetService<IUserService>(scope);
        var systemUser = await userService.GetUserByUsernameAsync("system");
        var newUserId = await userService.CreateUserAsync(new()
        {
            Username = "avataruser",
            Password = "AvatarPassword123",
            Name = "Avatar User",
            RepeatPassword = "AvatarPassword123",
        }, systemUser.Id);

        var testImagePath = Path.Combine(Directory.GetCurrentDirectory(), "assets", "test_image.jpg");
        using var fileStream = new FileStream(testImagePath, FileMode.Open, FileAccess.Read);
        IFormFile formFile = new FormFile(fileStream, 0, fileStream.Length, "file", "test_image.jpg")
        {
            Headers = new HeaderDictionary(),
            ContentType = "image/jpeg"
        };

        Func<Task> action = async () => await userService.ChangeAvatarAsync(newUserId, formFile);
        await action.Should().NotThrowAsync();

        var updatedUser = await userService.GetUserByIdAsync(newUserId);
        updatedUser.AvatarUrl.Should().NotBeNullOrEmpty();
        updatedUser.AvatarUrl.Should().Be("/avatars/avataruser.png");

        File.Exists(Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "avatars", "avataruser.png")).Should().BeTrue();
    }
}
