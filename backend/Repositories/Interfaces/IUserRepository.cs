using WorkspaceTracker.Api.Models.Entities;

namespace WorkspaceTracker.Api.Repositories.Interfaces;

/// <summary>
/// Defines data-access operations for the <see cref="User"/> entity.
/// </summary>
public interface IUserRepository
{
    Task<User?> GetByIdAsync(Guid id);
    Task<User?> GetByUsernameAsync(string username);
    Task<User?> GetByEmailAsync(string email);
    Task AddAsync(User user);
}
