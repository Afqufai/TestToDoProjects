namespace WorkspaceTracker.Api.Models.Entities;

/// <summary>
/// Represents a workspace project that contains a collection of tasks.
/// </summary>
public class Project
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public string Name { get; set; } = string.Empty;

    public string Description { get; set; } = string.Empty;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    /// <summary>Navigation property for the tasks belonging to this project.</summary>
    public ICollection<TaskItem> Tasks { get; set; } = new List<TaskItem>();
}
