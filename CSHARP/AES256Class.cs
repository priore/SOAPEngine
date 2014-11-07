using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Security.Cryptography;
using System.IO;
using System.Text;

// C# crypt/decrypt compatible with SOAPEngine iOS Framework.
namespace SOAPEngine.Cryptography
{
    public class AES256Class
    {
        public static string EncryptText(string input, string password)
        {
            // Get the bytes of the string
            byte[] bytesToBeEncrypted = UTF8Encoding.UTF8.GetBytes(input);
            byte[] passwordBytes = UTF8Encoding.UTF8.GetBytes(password);

            // Hash the password with SHA256
            passwordBytes = SHA256.Create().ComputeHash(passwordBytes);
            byte[] bytesEncrypted = AES_Encrypt(bytesToBeEncrypted, passwordBytes);
            return Convert.ToBase64String(bytesEncrypted);
        }

        public static byte[] AES_Encrypt(byte[] bytesToBeEncrypted, byte[] passwordBytes)
        {
            byte[] encryptedBytes = null;

            using (RijndaelManaged AES = new RijndaelManaged())
            {
                AES.KeySize = 256;
                AES.BlockSize = 128;
                AES.Mode = CipherMode.ECB;
                AES.Padding = PaddingMode.PKCS7;
                AES.Key = passwordBytes;

                using (ICryptoTransform encrypto = AES.CreateEncryptor())
                {
                    encryptedBytes = encrypto.TransformFinalBlock(bytesToBeEncrypted, 0, bytesToBeEncrypted.Length);
                }
            }

            return encryptedBytes;
        }


        public static string DecryptText(string input, string password)
        {
            // Get the bytes of the string
            byte[] bytesToBeDecrypted = Convert.FromBase64String(input);
            byte[] passwordBytes = UTF8Encoding.UTF8.GetBytes(password);
            passwordBytes = SHA256.Create().ComputeHash(passwordBytes);

            byte[] bytesDecrypted = AES_Decrypt(bytesToBeDecrypted, passwordBytes);
            return UTF8Encoding.UTF8.GetString(bytesDecrypted);
        }

        public static byte[] AES_Decrypt(byte[] bytesToBeDecrypted, byte[] passwordBytes)
        {
            byte[] decryptedBytes = null;

            using (RijndaelManaged AES = new RijndaelManaged())
            {
                AES.KeySize = 256;
                AES.BlockSize = 128;
                AES.Mode = CipherMode.ECB;
                AES.Padding = PaddingMode.PKCS7;
                AES.Key = passwordBytes;

                using (ICryptoTransform decrypto = AES.CreateDecryptor())
                {
                    decryptedBytes = decrypto.TransformFinalBlock(bytesToBeDecrypted, 0, bytesToBeDecrypted.Length);
                }
            }

            return decryptedBytes;
        }
    }
}