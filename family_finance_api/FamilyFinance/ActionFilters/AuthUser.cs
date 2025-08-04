using FamilyFinance.Controllers;
using Microsoft.AspNetCore.Mvc.Filters;

namespace FamilyFinance.ActionFilters;

public class AuthUser : ActionFilterAttribute
{
    public override void OnActionExecuting(ActionExecutingContext context)
    {
        // Check if the user is authenticated
        if (context.Controller is BaseController controller) {
            controller.CheckCurrentUser();
        }

        // Optionally, you can add more logic here to check user roles or permissions
        base.OnActionExecuting(context);
    }
}
