using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WorkspaceTracker.Api.Models.DTOs.Task;
using WorkspaceTracker.Api.Models.Entities;
using WorkspaceTracker.Api.Models.Enums;
using WorkspaceTracker.Api.Repositories.Interfaces;
using TaskStatus = WorkspaceTracker.Api.Models.Enums.TaskStatus;

namespace WorkspaceTracker.Api.Controllers;

/// <summary>
/// CRUD operations for project tasks. All endpoints require authentication.
/// </summary>
[Authorize]
[ApiController]
[Route("api")]
public class TaskController : ControllerBase
{
    private readonly ITaskRepository _taskRepository;
    private readonly IProjectRepository _projectRepository;

    public TaskController(ITaskRepository taskRepository, IProjectRepository projectRepository)
    {
        _taskRepository = taskRepository;
        _projectRepository = projectRepository;
    }

    /// <summary>Returns all tasks belonging to the specified project.</summary>
    [HttpGet("projects/{projectId:guid}/tasks")]
    [ProducesResponseType(typeof(IEnumerable<TaskDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<IEnumerable<TaskDto>>> GetProjectTasks(Guid projectId)
    {
        if (await _projectRepository.GetByIdAsync(projectId) is null)
            return NotFound(new { Message = $"Project with ID {projectId} not found." });

        var tasks = await _taskRepository.GetAllForProjectAsync(projectId);
        return Ok(tasks.Select(MapToDto));
    }

    /// <summary>Returns a single task by its unique identifier.</summary>
    [HttpGet("tasks/{id:guid}")]
    [ProducesResponseType(typeof(TaskDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<TaskDto>> GetById(Guid id)
    {
        var task = await _taskRepository.GetByIdAsync(id);
        if (task is null)
            return NotFound(new { Message = $"Task with ID {id} not found." });

        return Ok(MapToDto(task));
    }

    /// <summary>Creates a new task within the specified project.</summary>
    [HttpPost("tasks")]
    [ProducesResponseType(typeof(TaskDto), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<TaskDto>> Create([FromBody] CreateUpdateTaskDto dto)
    {
        if (await _projectRepository.GetByIdAsync(dto.ProjectId) is null)
            return BadRequest(new { Message = $"Project with ID {dto.ProjectId} does not exist." });

        if (!Enum.TryParse<TaskStatus>(dto.Status, ignoreCase: true, out var taskStatus))
            return BadRequest(new { Message = $"Invalid status '{dto.Status}'. Must be Todo, InProgress, or Done." });

        var task = new TaskItem
        {
            Title = dto.Title,
            Description = dto.Description,
            Status = taskStatus,
            ProjectId = dto.ProjectId,
            DueDate = dto.DueDate?.ToUniversalTime(),
            Priority = Enum.TryParse<TaskPriority>(dto.Priority, ignoreCase: true, out var createPriority)
                ? createPriority : TaskPriority.Medium,
            AssigneeId = dto.AssigneeId,
            CreatedAt = DateTime.UtcNow
        };

        await _taskRepository.AddAsync(task);

        return CreatedAtAction(nameof(GetById), new { id = task.Id }, MapToDto(task));
    }

    /// <summary>Updates an existing task.</summary>
    [HttpPut("tasks/{id:guid}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Update(Guid id, [FromBody] CreateUpdateTaskDto dto)
    {
        var task = await _taskRepository.GetByIdAsync(id);
        if (task is null)
            return NotFound(new { Message = $"Task with ID {id} not found." });

        if (await _projectRepository.GetByIdAsync(dto.ProjectId) is null)
            return BadRequest(new { Message = $"Project with ID {dto.ProjectId} does not exist." });

        if (!Enum.TryParse<TaskStatus>(dto.Status, ignoreCase: true, out var taskStatus))
            return BadRequest(new { Message = $"Invalid status '{dto.Status}'. Must be Todo, InProgress, or Done." });

        task.Title = dto.Title;
        task.Description = dto.Description;
        task.Status = taskStatus;
        task.ProjectId = dto.ProjectId;
        task.DueDate = dto.DueDate?.ToUniversalTime();
        task.Priority = Enum.TryParse<TaskPriority>(dto.Priority, ignoreCase: true, out var updatePriority)
            ? updatePriority : TaskPriority.Medium;
        task.AssigneeId = dto.AssigneeId;

        await _taskRepository.UpdateAsync(task);

        return NoContent();
    }

    /// <summary>Deletes a task by its unique identifier.</summary>
    [HttpDelete("tasks/{id:guid}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Delete(Guid id)
    {
        var task = await _taskRepository.GetByIdAsync(id);
        if (task is null)
            return NotFound(new { Message = $"Task with ID {id} not found." });

        await _taskRepository.DeleteAsync(id);

        return NoContent();
    }

    private static TaskDto MapToDto(TaskItem task) => new()
    {
        Id = task.Id,
        Title = task.Title,
        Description = task.Description,
        Status = task.Status.ToString(),
        DueDate = task.DueDate,
        Priority = task.Priority.ToString(),
        AssigneeId = task.AssigneeId,
        ProjectId = task.ProjectId,
        CreatedAt = task.CreatedAt
    };
}
