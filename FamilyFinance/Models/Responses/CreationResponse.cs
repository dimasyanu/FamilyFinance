namespace FamilyFinance.Models.Responses;

public class CreationResponse
{
    public Guid Id { get; set; }
    public CreationResponse()
    {
    }

    public CreationResponse(Guid id) => Id = id;
}
