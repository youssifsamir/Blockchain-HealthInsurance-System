// Import necessary modules
const ethers = require("ethers");
const fs = require("fs-extra");
require("dotenv").config();

// Main function to encrypt a private key and save it to a file
async function main() {
  // Create a wallet instance with the provided private key
  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY);

  // Encrypt the private key with a password
  const encryptedJsonKey = await wallet.encrypt(
    process.env.PRIVATE_KEY_PASSWORD,
    process.env.PRIVATE_KEY
  );

  // Write the encrypted key to a file
  fs.writeFileSync("./.encryptedKey.json", encryptedJsonKey);
}

// Execute the main function
main()
  .then(() => {
    // Exit the process with success status code
    console.log("Encryption completed successfully.");
    process.exit(0);
  })
  .catch((error) => {
    // Handle errors and exit the process with an error status code
    console.error("Error during encryption:", error);
    process.exit(1);
  });
