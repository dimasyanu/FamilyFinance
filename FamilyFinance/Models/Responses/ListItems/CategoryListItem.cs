using FamilyFinance.Models.Entities;

namespace FamilyFinance.Models.Responses.ListItems;

public class CategoryListItem
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string Color { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
    public Guid CreatedBy { get; set; }

    public CategoryListItem()
    {
    }

    public CategoryListItem(Category category)
    {
        Id = category.Id;
        Name = category.Name;
        Description = category.Description;
        Color = category.Color;
        CreatedAt = category.CreatedAt;
        CreatedBy = category.CreatedBy;
    }
}
