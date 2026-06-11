using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WorkspaceTracker.Api.Models.DTOs.Project;
using WorkspaceTracker.Api.Models.Entities;
using WorkspaceTracker.Api.Repositories.Interfaces;

namespace WorkspaceTracker.Api.Controllers;

/// <summary>
/// CRUD operations for workspace projects. All endpoints require authentication.
/// </summary>
[Authorize]
[ApiController]
[Route("api/projects")]
public class ProjectController : ControllerBase
{
    private readonly IProjectRepository _projectRepository;

    public ProjectController(IProjectRepository projectRepository)
    {
        _projectRepository = projectRepository;
    }

    /// <summary>Returns all projects ordered by creation date (newest first).</summary>
    [HttpGet]
    [ProducesResponseType(typeof(IEnumerable<ProjectDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<IEnumerable<ProjectDto>>> GetAll()
    {
        var projects = await _projectRepository.GetAllAsync();
        return Ok(projects.Select(MapToDto));
    }

    /// <summary>Returns a single project by its unique identifier.</summary>
    [HttpGet("{id:guid}")]
    [ProducesResponseType(typeof(ProjectDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<ProjectDto>> GetById(Guid id)
    {
        var project = await _projectRepository.GetByIdAsync(id);
        if (project is null)
            return NotFound(new { Message = $"Project with ID {id} not found." });

        return Ok(MapToDto(project));
    }

    /// <summary>Creates a new project resource.</summary>
    [HttpPost]
    [ProducesResponseType(typeof(ProjectDto), StatusCodes.Status201Created)]
    public async Task<ActionResult<ProjectDto>> Create([FromBody] CreateUpdateProjectDto dto)
    {
        var project = new Project
        {
            Name = dto.Name,
            Description = dto.Description,
            CreatedAt = DateTime.UtcNow
        };

        await _projectRepository.AddAsync(project);

        return CreatedAtAction(nameof(GetById), new { id = project.Id }, MapToDto(project));
    }

    /// <summary>Updates an existing project.</summary>
    [HttpPut("{id:guid}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Update(Guid id, [FromBody] CreateUpdateProjectDto dto)
    {
        var project = await _projectRepository.GetByIdAsync(id);
        if (project is null)
            return NotFound(new { Message = $"Project with ID {id} not found." });

        project.Name = dto.Name;
        project.Description = dto.Description;

        await _projectRepository.UpdateAsync(project);

        return NoContent();
    }

    /// <summary>Deletes a project and all associated tasks (cascade).</summary>
    [HttpDelete("{id:guid}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Delete(Guid id)
    {
        var project = await _projectRepository.GetByIdAsync(id);
        if (project is null)
            return NotFound(new { Message = $"Project with ID {id} not found." });

        await _projectRepository.DeleteAsync(id);

        return NoContent();
    }

    private static ProjectDto MapToDto(Project project) => new()
    {
        Id = project.Id,
        Name = project.Name,
        Description = project.Description,
        CreatedAt = project.CreatedAt
    };

    /// <summary>Retrieves health and task analytics for a specific project.</summary>
    [HttpGet("{projectId:guid}/analytics")]
    [ProducesResponseType(typeof(ProjectAnalyticsDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<ProjectAnalyticsDto>> GetProjectAnalytics(Guid projectId)
    {
        var project = await _projectRepository.GetByIdAsync(projectId);
        if (project is null)
            return NotFound(new { Message = $"Project with ID {projectId} not found." });

        var analytics = await _projectRepository.GetProjectAnalyticsAsync(projectId);
        return Ok(analytics);
    }
}
