using FamilyFinance.Exceptions;
using FamilyFinance.Models.Responses;
using Microsoft.AspNetCore.Diagnostics;
using ILogger = Serilog.ILogger;

namespace FamilyFinance.Middlewares;

public class GlobalExceptionHandler(ILogger logger) : IExceptionHandler
{
    private readonly ILogger _logger = logger ?? throw new ArgumentNullException(nameof(logger));

    /// <summary>
    /// Handles exceptions that occur during the request processing.
    /// </summary>
    /// <param name="httpContext"></param>
    /// <param name="exception"></param>
    /// <param name="cancellationToken"></param>
    /// <returns></returns>
    public async ValueTask<bool> TryHandleAsync(HttpContext httpContext, Exception exception, CancellationToken cancellationToken)
    {
        _logger.Error(exception, "An unhandled exception occurred: {Message}", exception.Message);

        var problemDetails = new Response<object> {
            Message = "An error occurred while processing your request.",
            Success = false,
            Data = null,
        };

        if (exception is UnauthorizedAccessException) {
            httpContext.Response.StatusCode = StatusCodes.Status401Unauthorized;
            problemDetails.Message = exception.Message ?? "Unauthorized access";
            problemDetails.Errors = ["Unauthorized"];
        }
        else if (exception is BadHttpRequestException) {
            httpContext.Response.StatusCode = StatusCodes.Status400BadRequest;
            problemDetails.Message = "Bad request: Invalid input or missing parameters.";
        }
        else if (exception is EntityNotFoundException) {
            httpContext.Response.StatusCode = StatusCodes.Status404NotFound;
            problemDetails.Message = exception.Message ?? "Resource not found.";
        }
        else {
            httpContext.Response.StatusCode = StatusCodes.Status500InternalServerError;
        }

        await httpContext.Response.WriteAsJsonAsync(problemDetails, cancellationToken);

        return true;
    }
}
