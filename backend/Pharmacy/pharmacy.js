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
const port = 5040;
const app = express();
const db = myDB.collection("stockLevel").doc("list");

tokens = [];

const fetch = require("node-fetch");

app.use(express.text());

app.listen(port, () => {
  // Log a message indicating that the server is running
  console.log(
    "\n" +
      currentTime() +
      `: Pharmacy Server is running on http://localhost:${port}`
  );
});

app.post("/queryStock", apiKeyMiddleware, async (req, res) => {
  // Retrieve the document from the Firestore database
  db.get()
    .then(async (doc) => {
      // Check if the document exists
      if (doc.exists) {
        // Log the timestamp when the querying is verified and data fetching begins
        console.log("\n" + currentTime() + ": Querying medicine...");

        medicineID = decryptData(req.body).medicineID;
        quantity = decryptData(req.body).quantity;
        medicineList = doc.data().list.medicines;

        for (let i = 0; i < medicineList.length; i++) {
          if (medicineList[i].id === medicineID) {
            console.log(
              "\n" +
                currentTime() +
                ": Medicine fetched, querying stock level..."
            );

            if (medicineList[i].count > quantity) {
              console.log("\n" + currentTime() + ": Medicine stock available.");

              await postDataToServer(
                "http://localhost:5040/sendRequest",
                req.body,
                {
                  "Content-type": "text/plain", // Set content type to text/plain
                  Authorization: process.env.API_SECRET_KEY, // Include API key for authorization
                }
              ).then((requestResponse) => {
                res.send(requestResponse.data);
              });
            } else if (medicineList[i].count < quantity) {
              console.log(
                "\n" + currentTime() + ": Medicine stock unavailable."
              );
              response = encryptData("Medicine stock unavailable.");
              res.send(response);
            }
          }
        }
      } else {
        // Log the timestamp when the medicine doesn't exist
        console.log(currentTime() + ": Medicine doesn't exist.");

        // Send a response indicating that the medicine doesn't exist
        res.send(encryptData("Medicine doesn't exist."));
      }
    })
    .catch((error) => {
      console.error("Error getting document --> ", error);
    });
});

app.post("/sendRequest", apiKeyMiddleware, async (req, res) => {
  request = decryptData(req.body);
  console.log("\n" + currentTime() + ": Request Received.");

  fetch("http://localhost:3000/api/message")
    .then((response) => {
      if (response.ok) {
        return response.json();
      }
      throw new Error("Network response was not ok.");
    })
    .then(async (data) => {
      if (data.message === "Accepted.") {
        await postDataToServer(
          "http://localhost:5040/acceptRequest",
          req.body,
          {
            "Content-type": "text/plain", // Set content type to text/plain
            Authorization: process.env.API_SECRET_KEY, // Include API key for authorization
          }
        ).then((requestResponse) => {
          res.send(requestResponse.data);
        });
      } else {
        await postDataToServer(
          "http://localhost:5040/declineRequest",
          req.body,
          {
            "Content-type": "text/plain", // Set content type to text/plain
            Authorization: process.env.API_SECRET_KEY, // Include API key for authorization
          }
        ).then((requestResponse) => {
          res.send(requestResponse.data);
        });
      }
    })
    .catch((error) => {
      console.error("There was a problem with the fetch operation:", error);
    });

  console.log("\n" + currentTime() + ": Request response sent to server.");
});

app.post("/acceptRequest", apiKeyMiddleware, async (req, res) => {
  console.log("\n" + currentTime() + ": Request Accepted.");
  tokens.push(decryptData(req.body).token);
  console.log("\n" + currentTime() + ": Token Received.");
  console.log("Live Tokens --> " + tokens);
  res.send(
    encryptData({
      response: "Stock Available, Request Accepted.",
      pid: "pid0x127",
    })
  );
});

app.post("/declineRequest", apiKeyMiddleware, async (req, res) => {
  res.send(encryptData("Stock Unavailable, Request Declined."));
});

app.post("/updateStockCount", apiKeyMiddleware, async (req, res) => {
  medID = decryptData(req.body).medicineID;
  console.log(medID);
  // Log a message indicating the start of the database update process
  console.log("\n" + currentTime() + ": Updating stock count...");

  // Update the Firestore database with the received data
  await db.update({
    ["list"]: {},
  });

  // Send a response to the sender with the HTTP status of the update operation
  res.send("Database updated.");
});

app.post("/claimPrescription", apiKeyMiddleware, async (req, res) => {
  await postDataToServer("http://localhost:5040/updateStockCount", req.body, {
    "Content-type": "text/plain", // Set content type to text/plain
    Authorization: process.env.API_SECRET_KEY, // Include API key for authorization
  }).then((requestResponse) => {
    res.send(requestResponse.data);
  });
});

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
