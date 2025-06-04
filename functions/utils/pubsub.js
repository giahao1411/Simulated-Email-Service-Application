const { PubSub } = require("@google-cloud/pubsub");

let pubsub;
try {
  pubsub = new PubSub();
  console.log("PubSub client initialized successfully");
} catch (error) {
  console.error("Error initializing PubSub:", error);
  throw error;
}

module.exports = pubsub;
