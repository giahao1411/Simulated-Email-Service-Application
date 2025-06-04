try {
  const { scheduleAutoReply } = require("./autoReply/scheduleAutoReply");
  const { processAutoReply } = require("./autoReply/processAutoReply");
  const { notifyNewEmail } = require("./notifications/notifyNewEmail");

  // Export functions
  exports.scheduleAutoReplyV2 = scheduleAutoReply;
  exports.processAutoReplyV2 = processAutoReply;
  exports.notifyNewEmailV2 = notifyNewEmail;

  console.log("All functions loaded successfully");
} catch (error) {
  console.error("Error loading functions:", error);
  throw error;
}
