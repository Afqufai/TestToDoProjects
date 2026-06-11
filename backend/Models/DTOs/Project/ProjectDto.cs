namespace WorkspaceTracker.Api.Models.DTOs.Project;

/// <summary>
/// Read-only data transfer object representing a project resource.
/// </summary>
public class ProjectDto
{
    public Guid Id { get; set; }

    public string Name { get; set; } = string.Empty;

    public string Description { get; set; } = string.Empty;

    public DateTime CreatedAt { get; set; }

    public double CompletionPercentage { get; set; }
}
