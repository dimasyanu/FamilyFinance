using FamilyFinance.Models.Entities;

namespace FamilyFinance.Models.Responses.ListItems;

public class CategoryListItem
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public int Icon { get; set; } = 0;
    public string Color { get; set; } = string.Empty;
    public string CreatedAt { get; set; } = string.Empty;
    public string CreatedBy { get; set; } = string.Empty;

    public CategoryListItem()
    {
    }

    public CategoryListItem(Category category)
    {
        Id = category.Id;
        Name = category.Name;
        Description = category.Description;
        Icon = category.Icon;
        Color = category.Color;
        CreatedAt = category.CreatedAt.ToString("dd MMM yyyy HH:mm");
        CreatedBy = category.CreatedBy.ToString();
    }
}
