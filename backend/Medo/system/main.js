// Load environment variables from a .env file
require("dotenv").config();

// Import necessary modules and utilities
const axios = require("axios");
const express = require("express");
const { myDB } = require("../firebase/firebase.js");

// Initializing database connection instance
const db = myDB.collection("transactions").doc("transactionList");

// Import utility functions for current time and API key middleware
const {
  currentDate,
  currentTime,
  apiKeyMiddleware,
} = require("../utilities/utility.js");

// Import encryption and decryption functions and constants
const {
  generateRandomID,
  encryptData,
  decryptData,
} = require("../utilities/encryptJSON.js");

// Define API endpoints for different services
const pharmacy = "http://localhost:5040/queryStock";
const insurance = "http://localhost:5050/receive-json";

// Set up Express server on the specified port
const port = 5020;
const app = express();
app.use(express.text());

// Start the Express server and listen on the specified port
app.listen(port, () => {
  // Log a message indicating that the System Server is running
  console.log(
    "\n" +
      currentTime() +
      ": System Server is running on http://localhost:" +
      port
  );
});

// Declare variables for transaction data
let id = 0; // To be retreived from somewhere

// Procedure function to handle the main transaction logic
const procedure = async (transaction) => {
  // Log the initiation of the transaction
  console.log("\n" + currentTime() + ": Transaction Initiated.");

  // Encrypt the 'transaction' object using the secret key and IV
  transaction = encryptData(transaction);

  // Create a JSON object containing headers for a POST request
  const headerJson = {
    "Content-type": "text/plain", // Set content type to text/plain
    Authorization: process.env.API_SECRET_KEY, // Include API key for authorization
  };

  // Log and perform validation with the insurance server
  console.log("\n" + currentTime() + ": Validating with insurance...");
  transaction = await postDataToServer(insurance, transaction, headerJson);

  // // Check if the decrypted data is valid JSON
  if (!JSON.stringify(decryptData(transaction.data)).includes("{")) {
    // If not a valid JSON set the transaction to "TERMINATED" and return the error message
    errorMsg = decryptData(transaction.data);
    console.log(currentTime() + ": " + errorMsg);
    console.log(currentTime() + ": Transaction terminated.");
    return transaction; // contains the error message
  }

  console.log(currentTime() + ": Validation completed.");

  // Log and request information from the nearest pharmacies
  console.log("\n" + currentTime() + ": Requesting nearest pharmacies...");

  pharamciesList = decryptData(transaction.data).pharmacyList;
  medicineName = decryptData(transaction.data).medicine;

  // Log and update transaction to DB
  await postDataToServer("http://localhost:5020/retrieveDB", medicineName, {
    "Content-type": "text/plain", // Set content type to text/plain
    Authorization: process.env.API_SECRET_KEY, // Include API key for authorization
  })
    .then((dbResponse) => {
      medicineID = dbResponse.data;
    })
    .catch((dbError) => {
      console.log(currentTime() + ": Error fetching Medicine ID.");
      console.log(currentTime() + ": Transaction terminated.");
      return transaction; // contains the error message
    });

  quantity = decryptData(transaction.data).quantity;
  request = encryptData({
    medicineID: medicineID,
    quantity: quantity,
    token: "testToken",
  });

  console.log("\n" + currentTime() + ": Medicine ID sent to pharmacy.");
  console.log(currentTime() + ": Waiting for pharamcy response...");

  pharmacyResponse = await postDataToServer(pharmacy, request, headerJson);
  pharmacyResponse = decryptData(pharmacyResponse.data);

  console.log(pharmacyResponse);

  transaction = decryptData(transaction.data);
  transaction.pharmacyID = pharmacyResponse.pid;
  transaction = encryptData(transaction);

  console.log(
    "\n" +
      currentTime() +
      ": Pharmacy Response --> " +
      pharmacyResponse.response
  );

  console.log(currentTime() + ": Token sent to pharmacy.");

  console.log(currentTime() + ": Medicine available at pharmacy A.");
  console.log(decryptData(transaction));
  // Return the transaction object
  return transaction;
};

// Endpoint to initiate a transaction
app.post("/initiateTransaction", apiKeyMiddleware, async (req, res) => {
  try {
    // Decrypt the incoming request body using provided encryption key and IV
    const decrypted = decryptData(req.body);

    // Load transaction data from a JSON file
    let transaction = require("./transaction.json");

    // Assign values to transaction object properties
    transaction.dateTime = currentDate() + " " + currentTime(); // Set the transaction date and time to the current timestamp
    transaction.id = decrypted.id; // Increment the ID and convert to string
    transaction.bill = 500; // Assign the decrypted bill to the transaction
    transaction.name = decrypted.name; // Assign the decrypted name to the transaction
    transaction.disease = decrypted.disease; // Assign the decrypted disease to the transaction
    transaction.medicine = decrypted.medicine; // Assign the decrypted medicine to the transaction
    transaction.zone = decrypted.zone; // Assign the decrypted zone to the transaction

    // Execute the main procedure
    transaction = await procedure(transaction);
    if (!JSON.stringify(decryptData(transaction)).includes("{")) {
      res.send(transaction);
      transaction = require("./transaction.json");
      return;
    }

    // Log and update transaction to DB
    await postDataToServer("http://localhost:5020/uploadDB", transaction.data, {
      "Content-type": "text/plain", // Set content type to text/plain
      Authorization: process.env.API_SECRET_KEY, // Include API key for authorization
    })
      .then((dbResponse) => {
        // Log the database response
        console.log(currentTime() + ": " + dbResponse.data);
      })
      .catch((dbError) => {
        // Log an error if there's an issue with the database request
        console.log("\n" + currentTime() + ": Error --> " + dbError.message);
      });

    // Clear transaction object
    transaction = require("./transaction.json");

    // Encrypt a response message with the secret key and IV
    const response = encryptData("Token claimed");

    // Send the encrypted response
    res.send(response);

    // Log a success message
    console.log("\n" + currentTime() + ": Transaction ended with success.");
  } catch (error) {
    // Log any errors that occur during the transaction
    console.log("\n" + currentTime() + ": " + error.message);
  }
});

// Endpoint to upload data to the database
app.post("/uploadDB", apiKeyMiddleware, async (req, res) => {
  // Log a message indicating the start of the database update process
  console.log("\n" + currentTime() + ": Updating database...");

  // Update the Firestore database with the received data
  await db.update({ [generateRandomID()]: req.body });

  // Send a response to the client with the HTTP status of the update operation
  res.send("Database updated.");
});

// Endpoint for handling POST requests to retrieve data from the database
app.post("/retrieveDB", apiKeyMiddleware, async (req, res) => {
  // Log the timestamp when the client verification process begins
  console.log("\n" + currentTime() + ": Fetching Medicine ID...");

  const medDoc = myDB.collection("medicines").doc("list");

  medDoc
    .get()
    .then((doc) => {
      if (doc.exists) {
        list = doc.data().medicines;

        for (let i = 0; i < list.length; i++) {
          if (list[i].name === req.body) {
            medID = list[i].id;
          }
        }

        console.log(currentTime() + ": Medicine ID fetched.");
        res.send(medID);
      } else {
        // Log the timestamp when the client doesn't exist
        console.log(currentTime() + ": Medicine doesn't exist.");

        // Send a response indicating that the client doesn't exist
        res.send("Medicine doesn't exist.");
      }
    })
    .catch((error) => {
      console.log(error);
    });
});

app.post("/finializeTransaction", apiKeyMiddleware, async (req, res) => {
  console.log("\n" + currentTime() + ": Finalizing transaction...");
  console.log("\n" + currentTime() + ": Contacting insurance...");
});

// Function to send encrypted data to a server
const postDataToServer = async (serverURL, encryptedData, headerJson) => {
  try {
    // Send a POST request to the specified server URL with the encrypted data
    const response = await axios.post(serverURL, encryptedData, {
      headers: headerJson,
    });

    // Return response from axios
    return response;
  } catch (error) {
    // Handle errors during the data sending process
    console.error(
      "\n" + currentTime() + ": Error sending data to Receiver Server\n",
      error.message
    );
  }
};
