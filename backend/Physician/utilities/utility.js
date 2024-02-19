require("dotenv").config();

// Function to get the current time in HH:MM:SS format
function currentTime() {
  // Get the current date and time
  let timeNow = new Date();

  // Extract hours, minutes, and seconds from the current time
  let hours = timeNow.getHours();
  let minutes = timeNow.getMinutes();
  let seconds = timeNow.getSeconds();

  // Return the current time in a formatted string
  return `[${hours}:${minutes}:${seconds}]`;
}

// Middleware function for API key authentication
const apiKeyMiddleware = (req, res, next) => {
  // Extract the API key from the request header
  const apiKey = req.header("Authorization");

  // Check if the API key matches the expected secret key
  if (apiKey === process.env.API_SECRET_KEY) {
    // Log a message indicating successful authorization
    console.log(
      "\n" + currentTime() + ": Request authorized with status code 200."
    );
    // Move to the next middleware or route handler
    next();
  } else {
    // Respond with a 401 Unauthorized status and a JSON error message
    res
      .status(401)
      .json("\n" + currentTime() + ": " + { error: "Unauthorized" });
  }
};

// Export the currentTime function to make it accessible in other modules
module.exports = { currentTime, apiKeyMiddleware };
