namespace WorkspaceTracker.Api.Models.Enums;

/// <summary>
/// Represents the priority level assigned to a task.
/// </summary>
public enum TaskPriority
{
    /// <summary>Low-priority task that can be addressed when convenient.</summary>
    Low,

    /// <summary>Default priority for standard tasks.</summary>
    Medium,

    /// <summary>High-priority task requiring immediate attention.</summary>
    High
}
