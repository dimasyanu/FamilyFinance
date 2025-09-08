
namespace FamilyFinance.Middlewares;

public class DelayMiddleware(IConfiguration config) : IMiddleware
{
    private readonly int _delayMilliseconds = int.Parse(config["AppConfig:DelayMilliseconds"] ?? "0");

    public async Task InvokeAsync(HttpContext context, RequestDelegate next)
    {
        if (_delayMilliseconds > 0) await Task.Delay(_delayMilliseconds);
        await next(context);
    }
}
