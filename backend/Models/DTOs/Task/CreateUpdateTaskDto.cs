using System.ComponentModel.DataAnnotations;

namespace WorkspaceTracker.Api.Models.DTOs.Task;

/// <summary>
/// Data transfer object for creating or updating a task.
/// </summary>
public class CreateUpdateTaskDto
{
    [Required]
    [StringLength(150, MinimumLength = 3)]
    public string Title { get; set; } = string.Empty;

    [StringLength(1000)]
    public string Description { get; set; } = string.Empty;

    [RegularExpression("^(Todo|InProgress|Done)$",
        ErrorMessage = "Status must be 'Todo', 'InProgress', or 'Done'.")]
    public string Status { get; set; } = "Todo";

    public DateTime? DueDate { get; set; }

    [RegularExpression("^(Low|Medium|High)$",
        ErrorMessage = "Priority must be 'Low', 'Medium', or 'High'.")]
    public string Priority { get; set; } = "Medium";

    public Guid? AssigneeId { get; set; }

    [Required]
    public Guid ProjectId { get; set; }
}
