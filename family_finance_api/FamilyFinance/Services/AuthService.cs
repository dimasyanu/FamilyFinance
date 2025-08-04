using FamilyFinance.Models.Requests;
using FamilyFinance.Models.Responses;
using FamilyFinance.Utils;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.Configuration;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace FamilyFinance.Services;

public class AuthService(IConfiguration config, AppDbContext dbContext)
{
    private readonly IConfiguration _config = config;
    private readonly AppDbContext _dbContext = dbContext;

    public async Task<LoginResponse> Authenticate(LoginRequest request)
    {
        if (string.IsNullOrEmpty(request.Username) || string.IsNullOrEmpty(request.Password)) {
            throw new UnauthorizedAccessException("Invalid username or password");
        }

        var user = await _dbContext.Users.FirstOrDefaultAsync(u => u.Username == request.Username)
            ?? throw new UnauthorizedAccessException("Invalid username or password");

        if (!PasswordUtil.VerifyPassword(request.Password, user.PasswordHash)) {
            throw new UnauthorizedAccessException("Invalid username or password");
        }

        var newRefreshToken = PasswordUtil.GenerateRandomAlphanumeric(64);
        user.RefreshToken = newRefreshToken;
        user.UpdatedAt = DateTime.Now;
        user.UpdatedBy = user.Id; // Assuming the user updates their own refresh token
        await _dbContext.SaveChangesAsync();

        var (accessToken, tokenExpiration) = GenerateToken(user.Username);
        return new LoginResponse {
            Username = user.Username,
            UserId = user.Id,
            AccessToken = accessToken,
            RefreshToken = newRefreshToken,
            Expiration = tokenExpiration
        };
    }

    public async Task<RefreshTokenResponse> RefreshToken(RefreshTokenRequest request)
    {
        if (string.IsNullOrEmpty(request.RefreshToken) || string.IsNullOrEmpty(request.Username)) {
            throw new UnauthorizedAccessException("Invalid refresh token or username");
        }

        var user = await _dbContext.Users.FirstOrDefaultAsync(u => u.Username == request.Username && u.RefreshToken == request.RefreshToken)
            ?? throw new UnauthorizedAccessException("Invalid username or refresh token");

        var (accessToken, tokenExpiration) = GenerateToken(user.Username);
        var newRefreshToken = PasswordUtil.GenerateRandomAlphanumeric(64);

        user.RefreshToken = newRefreshToken;
        user.UpdatedAt = DateTime.Now;
        user.UpdatedBy = user.Id; // Assuming the user updates their own refresh token
        await _dbContext.SaveChangesAsync();

        return new RefreshTokenResponse {
            AccessToken = accessToken,
            RefreshToken = newRefreshToken,
            Expiration = tokenExpiration
        };
    }

    public (string AccessToken, DateTime TokenExpiration) GenerateToken(string username)
    {
        var issuer = _config["JwtConfig:Issuer"] ?? throw new ConfigurationErrorsException("JWT Issuer is not defined");
        var audience = _config["JwtConfig:Audience"] ?? throw new ConfigurationErrorsException("JWT Audience is not defined");
        var secretKey = _config["JwtConfig:SecretKey"] ?? throw new ConfigurationErrorsException("JWT Secret Key is not defined");
        var secret = Encoding.UTF8.GetBytes(secretKey);
        var tokenValidityMinutes = _config.GetValue<int>("JwtConfig:ExpirationMinutes");
        var tokenExpiration = DateTime.Now.AddMinutes(tokenValidityMinutes);

        var tokenDescriptor = new SecurityTokenDescriptor {
            Subject = new ClaimsIdentity([ new Claim(ClaimTypes.Name, username) ]),
            Expires = tokenExpiration,
            Issuer = issuer,
            Audience = audience,
            SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(secret), SecurityAlgorithms.HmacSha256Signature)
        };
        var tokenHandler = new JwtSecurityTokenHandler();
        var token = tokenHandler.CreateToken(tokenDescriptor);
        return (tokenHandler.WriteToken(token), tokenExpiration);
    }
}
