using Dapper;
using WorkspaceTracker.Api.Data;
using WorkspaceTracker.Api.Models.Entities;
using WorkspaceTracker.Api.Repositories.Interfaces;

namespace WorkspaceTracker.Api.Repositories.Implementations;

/// <summary>
/// Implements <see cref="IUserRepository"/> using Dapper for reads
/// and EF Core for write operations to maintain change tracking.
/// </summary>
public class UserRepository : IUserRepository
{
    private readonly AppDbContext _context;
    private readonly DbConnectionFactory _connectionFactory;

    public UserRepository(AppDbContext context, DbConnectionFactory connectionFactory)
    {
        _context = context;
        _connectionFactory = connectionFactory;
    }

    /// <inheritdoc />
    public async Task<User?> GetByIdAsync(Guid id)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = """SELECT * FROM "Users" WHERE "Id" = @Id""";
        return await connection.QueryFirstOrDefaultAsync<User>(sql, new { Id = id });
    }

    /// <inheritdoc />
    public async Task<User?> GetByUsernameAsync(string username)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = """SELECT * FROM "Users" WHERE "Username" = @Username""";
        return await connection.QueryFirstOrDefaultAsync<User>(sql, new { Username = username });
    }

    /// <inheritdoc />
    public async Task<User?> GetByEmailAsync(string email)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = """SELECT * FROM "Users" WHERE "Email" = @Email""";
        return await connection.QueryFirstOrDefaultAsync<User>(sql, new { Email = email });
    }

    /// <inheritdoc />
    public async Task AddAsync(User user)
    {
        await _context.Users.AddAsync(user);
        await _context.SaveChangesAsync();
    }
}
