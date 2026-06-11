using System.Net;
using System.Text.Json;
using Microsoft.AspNetCore.Mvc;

namespace WorkspaceTracker.Api.Middleware;

/// <summary>
/// Global exception handling middleware that catches unhandled exceptions,
/// logs them via <see cref="ILogger"/>, and returns a standardised
/// <see cref="ProblemDetails"/> response to the client.
/// </summary>
public class ExceptionHandlingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<ExceptionHandlingMiddleware> _logger;
    private readonly IHostEnvironment _env;

    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase
    };

    public ExceptionHandlingMiddleware(
        RequestDelegate next,
        ILogger<ExceptionHandlingMiddleware> logger,
        IHostEnvironment env)
    {
        _next = next;
        _logger = logger;
        _env = env;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unhandled exception on {Method} {Path}",
                context.Request.Method, context.Request.Path);
            await HandleExceptionAsync(context, ex);
        }
    }

    private async Task HandleExceptionAsync(HttpContext context, Exception exception)
    {
        var (statusCode, title) = MapException(exception);

        context.Response.ContentType = "application/json";
        context.Response.StatusCode = (int)statusCode;

        var problemDetails = new ProblemDetails
        {
            Status = (int)statusCode,
            Type = $"https://httpstatuses.com/{(int)statusCode}",
            Title = title,
            Detail = exception.Message,
            Instance = context.Request.Path
        };

        if (_env.IsDevelopment())
        {
            problemDetails.Extensions["exception"] = exception.ToString();
        }

        var json = JsonSerializer.Serialize(problemDetails, JsonOptions);
        await context.Response.WriteAsync(json);
    }

    /// <summary>
    /// Maps a caught exception to the appropriate HTTP status code and title.
    /// </summary>
    private static (HttpStatusCode StatusCode, string Title) MapException(Exception exception) =>
        exception switch
        {
            KeyNotFoundException  => (HttpStatusCode.NotFound,            "Resource Not Found"),
            UnauthorizedAccessException => (HttpStatusCode.Unauthorized,  "Unauthorized Access"),
            ArgumentException     => (HttpStatusCode.BadRequest,          "Bad Request"),
            InvalidOperationException => (HttpStatusCode.BadRequest,      "Invalid Operation"),
            _                     => (HttpStatusCode.InternalServerError, "An error occurred while processing your request")
        };
}
