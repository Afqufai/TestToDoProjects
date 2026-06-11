using System.Data;
using Npgsql;

namespace WorkspaceTracker.Api.Data;

/// <summary>
/// Factory for creating raw <see cref="IDbConnection"/> instances
/// used by Dapper for lightweight read queries.
/// </summary>
public class DbConnectionFactory
{
    private readonly string _connectionString;

    public DbConnectionFactory(IConfiguration configuration)
    {
        _connectionString = configuration.GetConnectionString("DefaultConnection")
            ?? throw new InvalidOperationException(
                "Connection string 'DefaultConnection' is not configured.");
    }

    /// <summary>
    /// Creates a new <see cref="NpgsqlConnection"/> bound to the configured connection string.
    /// The caller is responsible for disposing the connection.
    /// </summary>
    public IDbConnection CreateConnection() => new NpgsqlConnection(_connectionString);
}
