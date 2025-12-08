using FamilyFinance.Abstractions;
using FamilyFinance.Exceptions;
using FamilyFinance.Models.Dtos;
using FamilyFinance.Models.Entities;
using FamilyFinance.Models.Requests;
using FamilyFinance.Models.Requests.ListFilters;
using FamilyFinance.Models.Responses;
using FamilyFinance.Models.Responses.ListItems;
using FamilyFinance.Utils;
using Microsoft.EntityFrameworkCore;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats.Png;

namespace FamilyFinance.Services;

public class UserService(AppDbContext dbContext) : BaseService(dbContext), IUserService
{
    /// <summary>
    /// Create a new user in the system.
    /// </summary>
    /// <param name="request"></param>
    /// <returns></returns>
    /// <exception cref="OperationCanceledException"></exception>
    public async Task<int> CreateUserAsync(UserSaveRequest request, int currentUserId)
    {
        var now = DateTime.Now;
        var newUser = new User {
            Name = request.Name,
            Username = request.Username,
            PasswordHash = PasswordUtil.HashPassword(request.Password),
            CreatedAt = now,
            CreatedBy = currentUserId,
            UpdatedAt = now,
            UpdatedBy = currentUserId,
        };
        await DbContext.Users.AddAsync(newUser);
        await DbContext.SaveChangesAsync();
        return newUser.Id;
    }

    /// <summary>
    /// Get a user by their ID.
    /// </summary>
    /// <param name="userId"></param>
    /// <returns></returns>
    /// <exception cref="NotImplementedException"></exception>
    public async Task<UserDto> GetUserByIdAsync(int userId)
    {
        var user = await DbContext.Users.FindAsync(userId)
            ?? throw new EntityNotFoundException($"User with ID {userId} not found.");
        return new UserDto(user);
    }

    /// <summary>
    /// Get a user by their username.
    /// </summary>
    /// <param name="userId"></param>
    /// <returns></returns>
    /// <exception cref="EntityNotFoundException"></exception>
    public async Task<UserDto> GetUserByUsernameAsync(string username)
    {
        var user = await DbContext.Users.FirstOrDefaultAsync(u => u.Username == username)
            ?? throw new EntityNotFoundException($"User with ID {username} not found.");
        return new UserDto(user);
    }

    /// <summary>
    /// Get a list of users with pagination and filtering options.
    /// </summary>
    /// <param name="filter"></param>
    /// <returns></returns>
    public async Task<Paginated<UserListItem>> ListAsync(UserListFilter filter)
    {
        var query = DbContext.Users.AsQueryable();
        if (!string.IsNullOrEmpty(filter.SearchTerm)) {
            query = query.Where(u => u.Name.ToLower().Contains(filter.SearchTerm.ToLower()) || u.Username.ToLower().Contains(filter.SearchTerm.ToLower()));
        }

        if (filter.IsActive != null) {
            query = query.Where(x => (x.DeletedAt == null) == filter.IsActive);
        }

        var count = await query.CountAsync();

        var items = await query
            .OrderBy(x => x.Username)
            .Skip((filter.Page - 1) * filter.PageSize)
            .Take(filter.PageSize)
            .ToListAsync();

        var results = new Paginated<UserListItem> {
            Items = items.Select(x => new UserListItem(x)),
            Page = filter.Page,
            PageSize = filter.PageSize,
            TotalCount = count,
        };
        return results;
    }

    /// <summary>
    /// Update an existing user.
    /// </summary>
    /// <param name="userId"></param>
    /// <param name="request"></param>
    /// <returns></returns>
    /// <exception cref="NotImplementedException"></exception>
    public async Task<UserDto> UpdateUserAsync(int userId, UserSaveRequest request, int currentUserId)
    {
        var user = await DbContext.Users.FindAsync(userId)
            ?? throw new EntityNotFoundException($"User with ID {userId} not found.");

        user.Name = request.Name;
        user.UpdatedAt = DateTime.Now;
        user.UpdatedBy = currentUserId;
        DbContext.Users.Update(user);
        await DbContext.SaveChangesAsync();

        return await GetUserByIdAsync(userId);
    }

    /// <summary>
    /// Update the refresh token for a user.
    /// </summary>
    /// <param name="userId"></param>
    /// <param name="refreshToken"></param>
    /// <returns></returns>
    /// <exception cref="EntityNotFoundException"></exception>
    public async Task<int> UpdateUserRefreshToken(int userId, string refreshToken)
    {
        var user = await DbContext.Users.FindAsync(userId)
            ?? throw new EntityNotFoundException($"User with ID {userId} not found.");
        user.RefreshToken = refreshToken;
        user.UpdatedAt = DateTime.Now;
        user.UpdatedBy = userId; // Assuming the user is updating their own refresh token
        DbContext.Users.Update(user);
        await DbContext.SaveChangesAsync();
        return user.Id;
    }

    /// <summary>
    /// Change the avatar for a user.
    /// </summary>
    /// <param name="userId"></param>
    /// <param name="file"></param>
    /// <returns></returns>
    /// <exception cref="EntityNotFoundException"></exception>
    public async Task<UserDto> ChangeAvatarAsync(int userId, IFormFile file)
    {
        var user = await DbContext.Users.FindAsync(userId)
            ?? throw new EntityNotFoundException($"User with ID {userId} not found.");

        // Store the file to wwwroot/avatars
        var uploadsDir = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "avatars");
        if (!Directory.Exists(uploadsDir)) {
            Directory.CreateDirectory(uploadsDir);
        }
        var newFileName = $"{user.Username}.png";
        var newFilePath = Path.Combine(uploadsDir, newFileName);
        using (var image = await Image.LoadAsync(file.OpenReadStream())) {
            await image.SaveAsync(newFilePath, new PngEncoder());
        }

        return new UserDto(user);
    }

    /// <summary>
    /// Update the password for a user.
    /// </summary>
    /// <param name="userId"></param>
    /// <param name="newPassword"></param>
    /// <param name="currentUserId"></param>
    /// <returns></returns>
    /// <exception cref="EntityNotFoundException"></exception>
    public async Task<int> ResetPassword(int userId, string newPassword, int currentUserId)
    {
        var user = await DbContext.Users.FindAsync(userId)
            ?? throw new EntityNotFoundException($"User with ID {userId} not found.");

        user.PasswordHash = PasswordUtil.HashPassword(newPassword);
        user.UpdatedAt = DateTime.Now;
        user.UpdatedBy = currentUserId;
        DbContext.Users.Update(user);
        await DbContext.SaveChangesAsync();
        return user.Id;
    }

    /// <summary>
    /// Delete a user by their ID.
    /// </summary>
    /// <param name="userId"></param>
    /// <returns></returns>
    /// <exception cref="NotImplementedException"></exception>
    public async Task DeleteUserAsync(int userId, int modifierId)
    {
        var user = await DbContext.Users.FindAsync(userId)
            ?? throw new EntityNotFoundException($"User with ID {userId} not found.");

        user.DeletedAt = DateTime.Now;
        user.DeletedBy = modifierId;

        await DbContext.SaveChangesAsync();
    }

    /// <summary>
    /// Restore a deleted user by their ID.
    /// </summary>
    /// <param name="userId"></param>
    /// <param name="currentUserId"></param>
    /// <returns></returns>
    public async Task<UserDto> RestoreAsync(int userId, int currentUserId)
    {
        var user = await DbContext.Users
            .FirstOrDefaultAsync(u => u.Id == userId && u.DeletedAt != null)
            ?? throw new EntityNotFoundException($"User with ID {userId} not found or not deleted.");

        user.UpdatedAt = DateTime.Now;
        user.UpdatedBy = currentUserId;
        user.DeletedAt = null;
        user.DeletedBy = null;

        await DbContext.SaveChangesAsync();
        return new UserDto(user);
    }
}
