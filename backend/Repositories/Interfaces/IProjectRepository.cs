using WorkspaceTracker.Api.Models.Entities;

namespace WorkspaceTracker.Api.Repositories.Interfaces;

/// <summary>
/// Defines data-access operations for the <see cref="Project"/> entity.
/// </summary>
public interface IProjectRepository
{
    Task<IEnumerable<Project>> GetAllAsync();
    Task<Project?> GetByIdAsync(Guid id);
    Task AddAsync(Project project);
    Task UpdateAsync(Project project);
    Task DeleteAsync(Guid id);
    Task<WorkspaceTracker.Api.Models.DTOs.Project.ProjectAnalyticsDto> GetProjectAnalyticsAsync(Guid projectId);
}
