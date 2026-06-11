using Dapper;
using WorkspaceTracker.Api.Data;
using WorkspaceTracker.Api.Models.Entities;
using WorkspaceTracker.Api.Repositories.Interfaces;

namespace WorkspaceTracker.Api.Repositories.Implementations;

/// <summary>
/// Implements <see cref="ITaskRepository"/> using Dapper for reads
/// and EF Core for write operations to maintain change tracking.
/// </summary>
public class TaskRepository : ITaskRepository
{
    private readonly AppDbContext _context;
    private readonly DbConnectionFactory _connectionFactory;

    public TaskRepository(AppDbContext context, DbConnectionFactory connectionFactory)
    {
        _context = context;
        _connectionFactory = connectionFactory;
    }

    /// <inheritdoc />
    public async Task<IEnumerable<TaskItem>> GetAllForProjectAsync(Guid projectId)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = """SELECT * FROM "Tasks" WHERE "ProjectId" = @ProjectId ORDER BY "CreatedAt" DESC""";
        return await connection.QueryAsync<TaskItem>(sql, new { ProjectId = projectId });
    }

    /// <inheritdoc />
    public async Task<TaskItem?> GetByIdAsync(Guid id)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = """SELECT * FROM "Tasks" WHERE "Id" = @Id""";
        return await connection.QueryFirstOrDefaultAsync<TaskItem>(sql, new { Id = id });
    }

    /// <inheritdoc />
    public async Task AddAsync(TaskItem task)
    {
        await _context.Tasks.AddAsync(task);
        await _context.SaveChangesAsync();
    }

    /// <inheritdoc />
    public async Task UpdateAsync(TaskItem task)
    {
        _context.Tasks.Update(task);
        await _context.SaveChangesAsync();
    }

    /// <inheritdoc />
    public async Task DeleteAsync(Guid id)
    {
        var task = await _context.Tasks.FindAsync(id);
        if (task is null) return;

        _context.Tasks.Remove(task);
        await _context.SaveChangesAsync();
    }
}
