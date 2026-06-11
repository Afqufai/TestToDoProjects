using System.ComponentModel.DataAnnotations;

namespace WorkspaceTracker.Api.Models.DTOs.Auth;

/// <summary>
/// Data transfer object for user login requests.
/// The <see cref="Username"/> field also accepts an email address.
/// </summary>
public class LoginDto
{
    [Required]
    public string Username { get; set; } = string.Empty;

    [Required]
    public string Password { get; set; } = string.Empty;
}
