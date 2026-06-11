using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.IdentityModel.Tokens;
using WorkspaceTracker.Api.Models.Entities;

namespace WorkspaceTracker.Api.Services;

/// <summary>
/// Generates signed JWT bearer tokens for authenticated users.
/// </summary>
public class TokenService
{
    private readonly IConfiguration _configuration;

    public TokenService(IConfiguration configuration)
    {
        _configuration = configuration;
    }

    /// <summary>
    /// Creates a signed JWT for the specified <paramref name="user"/>.
    /// </summary>
    /// <returns>A tuple containing the serialised token string and its UTC expiration time.</returns>
    public (string Token, DateTime ExpireAt) GenerateToken(User user)
    {
        var jwtSettings = _configuration.GetSection("Jwt");

        var keyString = jwtSettings["Key"]
            ?? throw new InvalidOperationException("JWT Key is not configured in appsettings.");

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(keyString));
        var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var claims = new[]
        {
            new Claim(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
            new Claim(JwtRegisteredClaimNames.UniqueName, user.Username),
            new Claim(JwtRegisteredClaimNames.Email, user.Email),
            new Claim(ClaimTypes.NameIdentifier, user.Id.ToString())
        };

        var expireMinutes = double.Parse(jwtSettings["ExpireMinutes"] ?? "60");
        var expireAt = DateTime.UtcNow.AddMinutes(expireMinutes);

        var token = new JwtSecurityToken(
            issuer: jwtSettings["Issuer"],
            audience: jwtSettings["Audience"],
            claims: claims,
            expires: expireAt,
            signingCredentials: credentials);

        return (new JwtSecurityTokenHandler().WriteToken(token), expireAt);
    }
}
