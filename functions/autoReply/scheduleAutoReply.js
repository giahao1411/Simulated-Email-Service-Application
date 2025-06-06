const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { db } = require("../firebase");
const tasks = require('@google-cloud/tasks');

const client = new tasks.v2.CloudTasksClient();
const project = 'cross-platform-57b89';
const queue = 'auto-reply-queue';
const location = 'us-central1';
const url = 'https://us-central1-cross-platform-57b89.cloudfunctions.net/processAutoReplyV2';

const scheduleAutoReply = onDocumentCreated(
  {
    document: "emails/{emailId}",
    region: "us-central1",
    memory: "512MiB",
    timeoutSeconds: 120,
    maxInstances: 1,
    concurrency: 1,
    minInstances: 0,
  },
  async (event) => {
    try {
      const snap = event.data;
      if (!snap) {
        console.log("No document data");
        return;
      }

      const emailData = snap.data();
      const emailId = event.params.emailId;

      console.log(`Processing email ${emailId}`);

      const from = emailData?.from;
      const to = emailData?.to || [];

      if (!from || to.length === 0) {
        console.log("Missing from or to email");
        return;
      }

      const { isAutoReply, isReplied, read } = emailData;

      if (isAutoReply || isReplied || read) {
        console.log("Email is auto reply, already replied, or read");
        return;
      }

      const senderEmail = from;
      const recipientEmail = to[0];

      const replySnapshot = await db
        .collection("emails")
        .where("from", "==", recipientEmail)
        .where("to", "array-contains", senderEmail)
        .where("isAutoReply", "==", true)
        .limit(1)
        .get();

      if (!replySnapshot.empty) {
        console.log("Auto reply already sent to this sender");
        return;
      }

      const userSnapshot = await db
        .collection("users")
        .where("email", "==", recipientEmail)
        .limit(1)
        .get();

      if (userSnapshot.empty) {
        console.log("User not found for email", { recipientEmail });
        return;
      }

      const userData = userSnapshot.docs[0].data();
      const autoReplyEnabled = userData.autoReplyEnabled || false;
      if (!autoReplyEnabled) {
        console.log("Auto reply is disabled for user", { recipientEmail });
        return;
      }

      const delaySeconds = 5 * 60; // 5 phút

      const messageData = {
        emailId,
        from: recipientEmail,
        to: senderEmail,
        subject: emailData?.subject || "Không có chủ đề",
        autoReplyMessage:
          "Cảm ơn bạn đã gửi email. Tôi sẽ trả lời bạn sớm nhất có thể.",
      };

      const task = {
        httpRequest: {
          httpMethod: 'POST',
          url,
          body: Buffer.from(JSON.stringify(messageData)).toString('base64'),
          headers: {
            'Content-Type': 'application/json',
          },
        },
        scheduleTime: {
          seconds: Math.floor(Date.now() / 1000) + delaySeconds,
        },
      };

      await client.createTask({
        parent: client.queuePath(project, location, queue),
        task,
      });

      console.log(
        `Scheduled auto reply for email ${emailId} with delay ${delaySeconds}s`
      );
    } catch (error) {
      console.error("Error in scheduleAutoReply:", error);
    }
  }
);

module.exports = { scheduleAutoReply };
