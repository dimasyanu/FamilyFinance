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
    Task<UserDto> GetUserByIdAsync(Guid userId);
    Task<UserDto> GetUserByUsernameAsync(string username);
    Task<Guid> CreateUserAsync(UserSaveRequest request, Guid currentUserId);
    Task<UserDto> UpdateUserAsync(Guid userId, UserSaveRequest request, Guid currentUserId);
    Task DeleteUserAsync(Guid userId, Guid currentUserId);
    Task<UserDto> RestoreAsync(Guid userId, Guid currentUserId);
}
