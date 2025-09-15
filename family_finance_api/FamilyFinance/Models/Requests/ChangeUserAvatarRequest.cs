using System.ComponentModel.DataAnnotations;

namespace FamilyFinance.Models.Requests;

public class ChangeUserAvatarRequest
{
    [Required]
    public IFormFile? File { get; set; }
}
