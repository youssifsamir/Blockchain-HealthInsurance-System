// Import the 'crypto' module for cryptographic operations
const crypto = require("crypto");

// Function to encrypt data using AES-256-CBC algorithm
function encryptData(data) {
  // Create a cipher using AES-256-CBC algorithm with the provided key and IV
  const cipher = crypto.createCipheriv(
    "aes-256-cbc",
    Buffer.from(process.env.CRYPTION_KEY),
    Buffer.from(process.env.CRYPTION_IV, "hex")
  );

  // Update the cipher with the JSON-stringified data, specifying input and output encoding
  let encryptedData = cipher.update(JSON.stringify(data), "utf-8", "hex");

  // Finalize the cipher and append the result to the encrypted data
  encryptedData += cipher.final("hex");

  // Return the encrypted data
  return encryptedData;
}

// Function to decrypt encrypted data
function decryptData(encryptedData) {
  // Create a decipher using AES-256-CBC algorithm with the provided key and IV
  const decipher = crypto.createDecipheriv(
    "aes-256-cbc",
    Buffer.from(process.env.CRYPTION_KEY),
    Buffer.from(process.env.CRYPTION_IV, "hex")
  );

  // Update the decipher with the encrypted data, specifying input and output encoding
  let decryptedData = decipher.update(encryptedData, "hex", "utf-8");

  // Finalize the decipher and append the result to the decrypted data
  decryptedData += decipher.final("utf-8");

  // Parse the decrypted data as JSON and return the result
  return JSON.parse(decryptedData);
}

// Exporting functions and variables for use in other modules
module.exports = { encryptData, decryptData };
