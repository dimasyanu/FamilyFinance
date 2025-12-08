using FamilyFinance.Models.Entities;
using Microsoft.EntityFrameworkCore;

namespace FamilyFinance.Utils;

public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<Account> Accounts { get; set; }
    public DbSet<Budget> Budgets { get; set; }
    public DbSet<Category> Categories { get; set; }
    public DbSet<Transaction> Transactions { get; set; }
    public DbSet<User> Users { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<Transaction>()
            .Property(t => t.Id)
            .HasColumnType("BINARY(16)");

        const int systemId = 1;
        const string timestamp = "2025-07-10T12:00:00Z";
        const string hash = "$2a$12$9MGisUIZgp80yLvdS5dCBORiaheBxVlBY6kN8SVfYLp4OxrMi6xZq";
        var dt = DateTime.Parse(timestamp);
        _ = modelBuilder.Entity<User>().HasData(
            new User() {
                Id = systemId,
                Name = "System Administrator",
                Username = "system",
                PasswordHash = hash,
                CreatedAt = dt,
                CreatedBy = systemId,
                UpdatedAt = dt,
                UpdatedBy = systemId,
            }
        );
    }
}
