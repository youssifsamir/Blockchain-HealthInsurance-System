// Import necessary modules and utilities
require("dotenv").config();
const axios = require("axios");
const fs = require("fs-extra");
const express = require("express");
const { ethers } = require("ethers");
const { myDB } = require("./firebase/firebase.js");
const { currentTime, apiKeyMiddleware } = require("./utilities/utility.js");
const {
  generateRandomID,
  encryptData,
  decryptData,
} = require("./utilities/cryption.js");

// Connect to Firestore and set up Express server
const port = 5050;
const app = express();
db = myDB.collection("clients");

// Middleware to parse JSON in incoming requests
app.use(express.text());

// Start the Express server and listen on the specified port
app.listen(port, () => {
  // Log a message indicating that the server is running
  console.log(
    "\n" +
      currentTime() +
      `: Insurance Server is running on http://localhost:${port}`
  );
});

// Endpoint to receive JSON data
app.post("/receive-json", apiKeyMiddleware, async (req, res) => {
  try {
    // Make a POST request to trigger a smart contract with the received data
    await axios
      .post("http://localhost:5050/triggerContract", req.body, {
        headers: {
          "Content-type": "text/plain", // Set content type to text/plain
          Authorization: process.env.API_SECRET_KEY, // Include API key for authorization
        },
      })
      .then(async (smartContractResponse) => {
        // Make a POST request to upload the smart contract response to the database
        await axios
          .post(
            "http://localhost:5050/retrieveDB",
            smartContractResponse.data,
            {
              headers: {
                "Content-type": "text/plain", // Set content type to text/plain
                Authorization: process.env.API_SECRET_KEY, // Include API key for authorization
              },
            }
          )
          .then((dbResponse) => {
            // Send the encrypted response
            res.send(dbResponse.data);
          })
          .catch((dbError) => {
            // Log an error if there's an issue with the database request
            console.log(
              "\n" + currentTime() + ": Error --> " + dbError.message
            );
          });
      })
      .catch((smartContractError) => {
        // Log an error if there's an issue with the smart contract request
        console.log(
          "\n" + currentTime() + ": Error --> " + smartContractError.message
        );
      });
  } catch (error) {
    // Log an error if there's an issue sending data to the Receiver Server
    console.error(
      "\n" + currentTime() + ": Error sending data to Receiver Server\n",
      error.message
    );
  }
});

// Endpoint to trigger a smart contract for client allowance balance checking
app.post("/triggerContract", apiKeyMiddleware, async (req, res) => {
  // Decrypt the response data using the received encryption key and IV
  const decrypted = decryptData(req.body);

  // Connect to Ethereum provider and wallet
  const provider = new ethers.providers.JsonRpcProvider(process.env.RPC_URL);
  const encryptedJSON = fs.readFileSync(
    "./smart_contract/.encryptedKey.json",
    "utf8"
  );

  // Create a new wallet using the encrypted JSON file and password
  let wallet = new ethers.Wallet.fromEncryptedJsonSync(
    encryptedJSON,
    process.env.PRIVATE_KEY_PASSWORD
  );

  // Log a message indicating the start of the wallet connection process
  console.log("\n" + currentTime() + ": Connecting wallet...");

  // Connect the wallet to the Ethereum provider
  wallet = await wallet.connect(provider);

  // Log a message indicating the successful connection of the wallet
  console.log(currentTime() + ": Wallet connected.");

  // Load the ABI (Application Binary Interface) of the smart contract
  const abi = fs.readFileSync(process.env.ABI, "utf-8");

  // Instantiate the smart contract using its address, ABI, and connected wallet
  const contract = new ethers.Contract(
    process.env.CONTRACT_ADDRESS,
    abi,
    wallet
  );

  // Log a message indicating the start of the smart contract interaction
  console.log(
    "\n" +
      currentTime() +
      ": Contacting smart contract, waiting for response..."
  );

  // Trigger the smart contract function "calculateAllowance" with a value of 1200
  const transaction = await contract.calculateAllowance(decrypted.bill);

  // Log the smart contract response
  console.log(
    currentTime() + ": Smart contract response = ",
    transaction.toString()
  );

  // Convert the 'transaction' object to a string and assign it to 'decrypted.allowance
  decrypted.allowance = transaction.toString();

  // Encrypt a response message
  const response = encryptData(decrypted);

  // Send the encrypted response
  res.send(response);
});

// Endpoint to trigger a smart contract for client allowance balance prescription fees deduction
app.post("deductContract", apiKeyMiddleware, async (req, res) => {
  // Decrypt the response data using the received encryption key and IV
  const decrypted = decryptData(req.body);

  // Connect to Ethereum provider and wallet
  const provider = new ethers.providers.JsonRpcProvider(process.env.RPC_URL);
  const encryptedJSON = fs.readFileSync(
    "./smart_contract/.encryptedKey.json",
    "utf8"
  );

  // Create a new wallet using the encrypted JSON file and password
  let wallet = new ethers.Wallet.fromEncryptedJsonSync(
    encryptedJSON,
    process.env.PRIVATE_KEY_PASSWORD
  );

  // Log a message indicating the start of the wallet connection process
  console.log("\n" + currentTime() + ": Connecting wallet...");

  // Connect the wallet to the Ethereum provider
  wallet = await wallet.connect(provider);

  // Log a message indicating the successful connection of the wallet
  console.log(currentTime() + ": Wallet connected.");

  // Load the ABI (Application Binary Interface) of the smart contract
  const abi = fs.readFileSync(process.env.ABI, "utf-8");

  // Instantiate the smart contract using its address, ABI, and connected wallet
  const contract = new ethers.Contract(
    process.env.CONTRACT2_ADDRESS,
    abi,
    wallet
  );

  // Log a message indicating the start of the smart contract interaction
  console.log(
    "\n" +
      currentTime() +
      ": Contacting smart contract, waiting for response..."
  );

  // Trigger the smart contract function "calculateAllowance" with a value of 1200
  const transaction = await contract.calculateAllowance(decrypted.bill);

  // Log the smart contract response
  console.log(
    currentTime() + ": Smart contract response = ",
    transaction.toString()
  );

  // Convert the 'transaction' object to a string and assign it to 'decrypted.allowance
  decrypted.allowance = transaction.toString();

  // Encrypt a response message
  const response = encryptData(decrypted);

  // Send the encrypted response
  res.send(response);
});

// Endpoint for handling POST requests to retrieve data from the database
app.post("/retrieveDB", apiKeyMiddleware, async (req, res) => {
  // Log the timestamp when the client verification process begins
  console.log("\n" + currentTime() + ": Verifying client...");

  // Decrypt the data received in the request body
  const transaction = decryptData(req.body);

  // Access the Firestore document associated with the client's ID
  const clientDocument = db.doc(transaction.id);

  // Retrieve the client's document from the Firestore database
  clientDocument
    .get()
    .then((doc) => {
      // Check if the client document exists
      if (doc.exists) {
        // Log the timestamp when the client is verified and data fetching begins
        console.log(
          currentTime() +
            ": Client verified." +
            "\n\n" +
            currentTime() +
            ": Fetching client data..."
        );

        // Decrypt the encrypted data stored in the client's Firestore document
        data = decryptData(doc.data().encryptedData);

        // Update the transaction object with relevant client data
        transaction.name = data.firstname + " " + data.lastname;
        transaction.allowance = data.allowance;
        transaction.insurance = "testInsurance"; // Placeholder for insurance data

        // Log the timestamp when client data is successfully fetched
        console.log(currentTime() + ": Client data fetched.");

        console.log("\n" + currentTime() + ": Fetching pharmacies list...");
        const pharmaciesDocument = myDB
          .collection("pharmacies")
          .doc("pharmaciesList");

        pharmaciesDocument
          .get()
          .then((doc) => {
            if (doc.exists) {
              // Access the data from the document
              pharmacyList = decryptData(doc.data().encryptedList);

              pharmacyList = pharmacyList.pharmacies.filter(
                (pharmacy) => pharmacy.zone == transaction.zone
              );

              transaction.pharmacyList = pharmacyList;
              console.log(currentTime() + ": Pharmacies list fetched.");
              res.send(encryptData(transaction));
            } else {
              console.log(currentTime() + ": Error filtering pharmacies.");
            }
          })
          .catch((error) => {
            console.error(
              currentTime() + ": Error fetching pharmacies document.\n" + error
            );
            res.send(encryptData("Error fetching pharmacies document."));
          });
      } else {
        // Log the timestamp when the client doesn't exist
        console.log(currentTime() + ": Client doesn't exist.");

        // Send a response indicating that the client doesn't exist
        res.send(encryptData("Client doesn't exist."));
      }
    })
    .catch((error) => {
      console.log(error);
    });
});
