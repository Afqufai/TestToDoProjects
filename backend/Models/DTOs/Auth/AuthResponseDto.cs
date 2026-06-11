namespace WorkspaceTracker.Api.Models.DTOs.Auth;

/// <summary>
/// Response payload returned after a successful authentication.
/// </summary>
public class AuthResponseDto
{
    public string Token { get; set; } = string.Empty;

    public string Username { get; set; } = string.Empty;

    public string Email { get; set; } = string.Empty;

    public DateTime ExpireAt { get; set; }
}
