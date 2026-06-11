using TaskStatus = WorkspaceTracker.Api.Models.Enums.TaskStatus;

namespace WorkspaceTracker.Api.Models.Entities;

/// <summary>
/// Represents an individual task that belongs to a <see cref="Project"/>.
/// </summary>
public class TaskItem
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public string Title { get; set; } = string.Empty;

    public string Description { get; set; } = string.Empty;

    public TaskStatus Status { get; set; } = TaskStatus.Todo;

    public Guid ProjectId { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    /// <summary>Navigation property for the parent project.</summary>
    public Project? Project { get; set; }
}
