using WorkspaceTracker.Api.Models.Entities;

namespace WorkspaceTracker.Api.Repositories.Interfaces;

/// <summary>
/// Defines data-access operations for the <see cref="TaskItem"/> entity.
/// </summary>
public interface ITaskRepository
{
    Task<IEnumerable<TaskItem>> GetAllForProjectAsync(Guid projectId);
    Task<TaskItem?> GetByIdAsync(Guid id);
    Task AddAsync(TaskItem task);
    Task UpdateAsync(TaskItem task);
    Task DeleteAsync(Guid id);
}
