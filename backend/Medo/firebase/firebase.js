// Import necessary modules from Firebase Admin SDK
const { initializeApp, cert } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");

// Load service account credentials from a JSON file
const serviceAccount = require("./creds.json");

// Initialize the Firebase Admin SDK with the provided credentials
initializeApp({
  credential: cert(serviceAccount),
});

// Get a reference to the Firestore database
const myDB = getFirestore();

// Export the Firestore database reference for use in other modules
module.exports = { myDB };
