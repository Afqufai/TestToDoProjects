using Dapper;
using WorkspaceTracker.Api.Data;
using WorkspaceTracker.Api.Models.Entities;
using WorkspaceTracker.Api.Repositories.Interfaces;

namespace WorkspaceTracker.Api.Repositories.Implementations;

/// <summary>
/// Implements <see cref="IProjectRepository"/> using Dapper for reads
/// and EF Core for write operations to maintain change tracking.
/// </summary>
public class ProjectRepository : IProjectRepository
{
    private readonly AppDbContext _context;
    private readonly DbConnectionFactory _connectionFactory;

    public ProjectRepository(AppDbContext context, DbConnectionFactory connectionFactory)
    {
        _context = context;
        _connectionFactory = connectionFactory;
    }

    /// <inheritdoc />
    public async Task<IEnumerable<Project>> GetAllAsync()
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = """SELECT * FROM "Projects" ORDER BY "CreatedAt" DESC""";
        return await connection.QueryAsync<Project>(sql);
    }

    /// <inheritdoc />
    public async Task<Project?> GetByIdAsync(Guid id)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = """SELECT * FROM "Projects" WHERE "Id" = @Id""";
        return await connection.QueryFirstOrDefaultAsync<Project>(sql, new { Id = id });
    }

    /// <inheritdoc />
    public async Task AddAsync(Project project)
    {
        await _context.Projects.AddAsync(project);
        await _context.SaveChangesAsync();
    }

    /// <inheritdoc />
    public async Task UpdateAsync(Project project)
    {
        _context.Projects.Update(project);
        await _context.SaveChangesAsync();
    }

    /// <inheritdoc />
    public async Task DeleteAsync(Guid id)
    {
        var project = await _context.Projects.FindAsync(id);
        if (project is null) return;

        _context.Projects.Remove(project);
        await _context.SaveChangesAsync();
    }

    /// <inheritdoc />
    public async Task<WorkspaceTracker.Api.Models.DTOs.Project.ProjectAnalyticsDto> GetProjectAnalyticsAsync(Guid projectId)
    {
        using var connection = _connectionFactory.CreateConnection();
        
        const string sql = """
            SELECT 
                COUNT(*)::INT AS "TotalTasks",
                COUNT(CASE WHEN "Status" = 'Done' THEN 1 END)::INT AS "CompletedTasks",
                CASE 
                    WHEN COUNT(*) = 0 THEN 0.0 
                    ELSE ROUND((COUNT(CASE WHEN "Status" = 'Done' THEN 1 END) * 100.0) / COUNT(*), 2)::FLOAT
                END AS "CompletionPercentage",
                COUNT(CASE WHEN "Status" IN ('Todo', 'InProgress') AND "CreatedAt" < NOW() - INTERVAL '7 days' THEN 1 END)::INT AS "BottleneckTasks"
            FROM "Tasks"
            WHERE "ProjectId" = @ProjectId
            """;

        var result = await connection.QuerySingleOrDefaultAsync<WorkspaceTracker.Api.Models.DTOs.Project.ProjectAnalyticsDto>(sql, new { ProjectId = projectId });
        
        return result ?? new WorkspaceTracker.Api.Models.DTOs.Project.ProjectAnalyticsDto();
    }
}
