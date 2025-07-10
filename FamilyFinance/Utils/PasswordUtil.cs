using System.Security.Cryptography;
using System.Text;
using Bc = BCrypt.Net.BCrypt;

namespace FamilyFinance.Utils;

public static class PasswordUtil
{
    private const string AlphanumericCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

    public static string HashPassword(string password, int workFactor = 12) => Bc.HashPassword(password, workFactor);
    public static bool VerifyPassword(string password, string hashedPassword) => Bc.Verify(password, hashedPassword);

    public static string GenerateRandomAlphanumeric(int length)
    {
        var result = new StringBuilder(length);
        using (var rng = RandomNumberGenerator.Create()) {
            var buffer = new byte[sizeof(uint)];

            while (result.Length < length) {
                rng.GetBytes(buffer);
                uint num = BitConverter.ToUInt32(buffer, 0);
                result.Append(AlphanumericCharacters[(int)(num % AlphanumericCharacters.Length)]);
            }
        }

        return result.ToString();
    }
}
