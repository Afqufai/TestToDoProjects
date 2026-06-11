namespace WorkspaceTracker.Api.Models.DTOs.Task;

/// <summary>
/// Read-only data transfer object representing a task resource.
/// </summary>
public class TaskDto
{
    public Guid Id { get; set; }

    public string Title { get; set; } = string.Empty;

    public string Description { get; set; } = string.Empty;

    public string Status { get; set; } = string.Empty;

    public Guid ProjectId { get; set; }

    public DateTime CreatedAt { get; set; }
}
