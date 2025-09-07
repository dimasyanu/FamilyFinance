
namespace FamilyFinance.Middlewares;

public class DelayMiddleware : IMiddleware
{
    public async Task InvokeAsync(HttpContext context, RequestDelegate next)
    {
        await Task.Delay(100); // Simulate a delay of 100 milliseconds
        await next(context); // Call the next middleware in the pipeline
    }
}
