using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using WorkspaceTracker.Api.Models.DTOs.Auth;
using WorkspaceTracker.Api.Models.Entities;
using WorkspaceTracker.Api.Repositories.Interfaces;
using WorkspaceTracker.Api.Services;

namespace WorkspaceTracker.Api.Controllers;

/// <summary>
/// Handles user registration and JWT-based authentication.
/// </summary>
[ApiController]
[Route("api/auth")]
public class AuthController : ControllerBase
{
    private readonly IUserRepository _userRepository;
    private readonly TokenService _tokenService;
    private readonly PasswordHasher<User> _passwordHasher = new();

    public AuthController(IUserRepository userRepository, TokenService tokenService)
    {
        _userRepository = userRepository;
        _tokenService = tokenService;
    }

    /// <summary>
    /// Registers a new user account after validating uniqueness of username and email.
    /// </summary>
    [HttpPost("register")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Register([FromBody] RegisterDto dto)
    {
        if (await _userRepository.GetByUsernameAsync(dto.Username) is not null)
            return BadRequest(new { Message = "Username is already taken." });

        if (await _userRepository.GetByEmailAsync(dto.Email) is not null)
            return BadRequest(new { Message = "Email is already registered." });

        var user = new User
        {
            Username = dto.Username,
            Email = dto.Email
        };

        user.PasswordHash = _passwordHasher.HashPassword(user, dto.Password);

        await _userRepository.AddAsync(user);

        return Ok(new { Message = "Registration successful." });
    }

    /// <summary>
    /// Authenticates a user by username or email and returns a signed JWT.
    /// </summary>
    [HttpPost("login")]
    [ProducesResponseType(typeof(AuthResponseDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> Login([FromBody] LoginDto dto)
    {
        var user = await _userRepository.GetByUsernameAsync(dto.Username)
            ?? (dto.Username.Contains('@')
                ? await _userRepository.GetByEmailAsync(dto.Username)
                : null);

        if (user is null)
            return Unauthorized(new { Message = "Invalid username/email or password." });

        var result = _passwordHasher.VerifyHashedPassword(user, user.PasswordHash, dto.Password);
        if (result == PasswordVerificationResult.Failed)
            return Unauthorized(new { Message = "Invalid username/email or password." });

        var (token, expireAt) = _tokenService.GenerateToken(user);

        return Ok(new AuthResponseDto
        {
            Token = token,
            Username = user.Username,
            Email = user.Email,
            ExpireAt = expireAt
        });
    }
}
