namespace WorkspaceTracker.Api.Models.Enums;

/// <summary>
/// Represents the lifecycle status of a task within a project.
/// </summary>
public enum TaskStatus
{
    /// <summary>Task has been created but work has not yet started.</summary>
    Todo,

    /// <summary>Task is actively being worked on.</summary>
    InProgress,

    /// <summary>Task has been completed.</summary>
    Done
}
