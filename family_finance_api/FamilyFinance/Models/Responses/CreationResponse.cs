namespace FamilyFinance.Models.Responses;

public class CreationResponse<TId>
{
    public TId? Id { get; set; }
    public CreationResponse()
    {
    }

    public CreationResponse(TId id) => Id = id;
}
