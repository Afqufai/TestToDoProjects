using System.ComponentModel.DataAnnotations;

namespace WorkspaceTracker.Api.Models.DTOs.Project;

/// <summary>
/// Data transfer object for creating or updating a project.
/// </summary>
public class CreateUpdateProjectDto
{
    [Required]
    [StringLength(100, MinimumLength = 3)]
    public string Name { get; set; } = string.Empty;

    [StringLength(500)]
    public string Description { get; set; } = string.Empty;
}
