using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Security.Cryptography;
using System.IO;
using System.Text;

namespace Priore.Cryptography
{
    public class TripleDESClass
    {
        public static string EncryptText(string input, string password)
        {
            // Get the bytes of the string
            byte[] bytesToBeEncrypted = UTF8Encoding.UTF8.GetBytes(input);
            byte[] passwordBytes = UTF8Encoding.UTF8.GetBytes(password);

            // Hash the password with SHA256
            passwordBytes = SHA256.Create().ComputeHash(passwordBytes).Take(24).ToArray();
            byte[] bytesEncrypted = TripleDES_Encrypt(bytesToBeEncrypted, passwordBytes);
            return Convert.ToBase64String(bytesEncrypted);
        }

        public static byte[] TripleDES_Encrypt(byte[] bytesToBeEncrypted, byte[] passwordBytes)
        {
            byte[] encryptedBytes = null;

            using (TripleDESCryptoServiceProvider tdes = new TripleDESCryptoServiceProvider())
            {
                tdes.KeySize = 192;
                tdes.BlockSize = 64;
                tdes.Mode = CipherMode.ECB;
                tdes.Padding = PaddingMode.PKCS7;
                tdes.Key = passwordBytes;

                using (ICryptoTransform encrypto = tdes.CreateEncryptor())
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
            passwordBytes = SHA256.Create().ComputeHash(passwordBytes).Take(24).ToArray();

            byte[] bytesDecrypted = TripleDES_Decrypt(bytesToBeDecrypted, passwordBytes);
            return UTF8Encoding.UTF8.GetString(bytesDecrypted);
        }

        public static byte[] TripleDES_Decrypt(byte[] bytesToBeDecrypted, byte[] passwordBytes)
        {
            byte[] decryptedBytes = null;

            using (TripleDESCryptoServiceProvider tdes = new TripleDESCryptoServiceProvider())
            {
                tdes.KeySize = 192;
                tdes.BlockSize = 64;
                tdes.Mode = CipherMode.ECB;
                tdes.Padding = PaddingMode.PKCS7;
                tdes.Key = passwordBytes;

                using (ICryptoTransform decrypto = tdes.CreateDecryptor())
                {
                    decryptedBytes = decrypto.TransformFinalBlock(bytesToBeDecrypted, 0, bytesToBeDecrypted.Length);
                }
            }

            return decryptedBytes;
        }
    }
}