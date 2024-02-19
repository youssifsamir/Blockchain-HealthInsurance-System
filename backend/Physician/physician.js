// Import necessary modules and dependencies
const axios = require("axios");
const express = require("express");
const { currentTime, apiKeyMiddleware } = require("./utilities/utility.js");
const { encryptData, decryptData } = require("./utilities/encryptJSON.js");

// Set the port number for the Express server
const port = 5080;

// Create an instance of the Express application
const app = express();

// Middleware to parse JSON in incoming requests
app.use(express.json());
app.use(express.text());

// Start the Express server and listen on the specified port
app.listen(port, () => {
  console.log(
    "\n" +
      currentTime() +
      ": Physician Server is running on http://localhost:" +
      port
  );
});

app.post("/terminateTransaction", apiKeyMiddleware, async (req, res) => {
  errorMsg = decryptData(req.body);
  console.log("\n" + currentTime() + errorMsg);
});

// Define a route for handling POST requests to issue a prescription
app.post("/issuePrescription", apiKeyMiddleware, async (req, res) => {
  // Log a message indicating that prescription issuance is in progress
  console.log("\n" + currentTime() + ": Issuing prescription...");

  // Encrypt the request body using the encryptData function
  const encrypted = encryptData(req.body);

  // Make an asynchronous POST request to another server using Axios
  await axios
    .post("http://localhost:5020/initiateTransaction", encrypted, {
      headers: {
        "Content-type": "text/plain", // Set content type to text/plain
        Authorization: process.env.API_SECRET_KEY, // Include API key for authorization
      },
    })
    .then((response) => {
      // Decrypt the data using the encryption key and IV from response headers
      const decrypted = decryptData(response.data);

      // Log the response message
      console.log(currentTime() + ": " + decrypted);

      // Send a response to the client indicating successful prescription issuance
      res.send(decrypted);
    })
    .catch((error) => {
      // Log an error message if the POST request fails
      console.error("\n" + currentTime() + ": Error --> ", error.message);

      // Send a response to the client indicating failure to issue the prescription
      res.send(decryptData(error.message));
    });
});
