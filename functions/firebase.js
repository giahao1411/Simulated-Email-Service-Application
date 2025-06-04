const admin = require("firebase-admin");

// Khởi tạo Firebase Admin SDK
try {
  if (!admin.apps.length) {
    admin.initializeApp();
  }
} catch (error) {
  console.error("Error initializing Firebase Admin:", error);
  throw error;
}

const db = admin.firestore();
const messaging = admin.messaging();

module.exports = { admin, db, messaging };
