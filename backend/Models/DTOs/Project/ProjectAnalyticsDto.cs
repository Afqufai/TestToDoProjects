namespace WorkspaceTracker.Api.Models.DTOs.Project;

/// <summary>
/// DTO representing health and progress analytics for a specific project.
/// </summary>
public class ProjectAnalyticsDto
{
    public int TotalTasks { get; set; }
    public int CompletedTasks { get; set; }
    public double CompletionPercentage { get; set; }
    
    /// <summary>
    /// Number of active tasks that have been in 'Todo' or 'InProgress' for more than 7 days.
    /// </summary>
    public int BottleneckTasks { get; set; }
}
