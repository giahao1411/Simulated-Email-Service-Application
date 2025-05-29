const { scheduleAutoReply } = require("./autoReply/scheduleAutoReply");
const { processAutoReply } = require("./autoReply/processAutoReply");
const { notifyNewEmail } = require("./notifications/notifyNewEmail");

exports.scheduleAutoReply = scheduleAutoReply;
exports.processAutoReply = processAutoReply;
exports.notifyNewEmail = notifyNewEmail;
