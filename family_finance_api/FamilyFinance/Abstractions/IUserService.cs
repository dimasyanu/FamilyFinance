using FamilyFinance.Models.Dtos;
using FamilyFinance.Models.Requests;
using FamilyFinance.Models.Requests.ListFilters;
using FamilyFinance.Models.Responses;
using FamilyFinance.Models.Responses.ListItems;

namespace FamilyFinance.Abstractions;

public interface IUserService
{
    // Define methods that the UserService should implement
    // For example:
    Task<Paginated<UserListItem>> ListAsync(UserListFilter filter);
    Task<UserDto> GetUserByIdAsync(int userId);
    Task<UserDto> GetUserByUsernameAsync(string username);
    Task<int> CreateUserAsync(UserSaveRequest request, int currentUserId);
    Task<UserDto> UpdateUserAsync(int userId, UserSaveRequest request, int currentUserId);
    Task<UserDto> ChangeAvatarAsync(int userId, IFormFile file);
    Task DeleteUserAsync(int userId, int currentUserId);
    Task<UserDto> RestoreAsync(int userId, int currentUserId);
}
