using FamilyFinance.Models.Entities;
using Microsoft.EntityFrameworkCore;

namespace FamilyFinance.Utils;

public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<Category> Categories { get; set; }
    public DbSet<Transaction> Transactions { get; set; }
    public DbSet<User> Users { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        const string systemId = "de178780-234b-49c9-b5cd-f01fe5edb4d2";
        const string timestamp = "2025-07-10T12:00:00Z";
        const string hash = "$2a$12$9MGisUIZgp80yLvdS5dCBORiaheBxVlBY6kN8SVfYLp4OxrMi6xZq";
        var dt = DateTime.Parse(timestamp);
        var systemGuid = Guid.Parse(systemId);
        _ = modelBuilder.Entity<User>().HasData(
            new User() {
                Id = systemGuid,
                Name = "System Administrator",
                Username = "system",
                PasswordHash = hash,
                CreatedAt = dt,
                CreatedBy = systemGuid,
                UpdatedAt = dt,
                UpdatedBy = systemGuid,
            }
        );
    }
}
