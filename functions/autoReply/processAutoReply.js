const { onMessagePublished } = require("firebase-functions/v2/pubsub");
const { db, admin } = require("../firebase");

exports.processAutoReply = onMessagePublished(
  {
    topic: "send-auto-reply",
    region: "us-central1",
    memory: "512MiB",
    timeoutSeconds: 120,
    maxInstances: 1,
    concurrency: 1,
    minInstances: 0,
  },
  async (event) => {
    try {
      const message = event.data?.message;
      if (!message) {
        console.log("No message data");
        return;
      }

      const messageData = message.json || {};
      const { emailId, from, to, subject, autoReplyMessage } = messageData;

      console.log(`Processing auto reply for email ${emailId}`);

      if (!emailId || !from || !to) {
        console.log("Missing required fields");
        return;
      }

      // Kiểm tra email gốc còn tồn tại và chưa được reply
      const emailDoc = await db.collection("emails").doc(emailId).get();

      if (!emailDoc.exists) {
        console.log(`Original email ${emailId} not found`);
        return;
      }

      const emailData = emailDoc.data();
      if (emailData.isReplied) {
        console.log(`Email ${emailId} already replied`);
        return;
      }

      // Tạo email auto reply
      const autoReplyData = {
        from,
        to: [to],
        subject: `Tự động trả lời: ${subject}`,
        body: autoReplyMessage,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        isReplied: false,
        read: false,
        starred: false,
        labels: [],
        isAutoReply: true,
      };

      // Thêm email reply vào collection
      await db.collection("emails").add(autoReplyData);

      // Cập nhật email gốc là đã reply
      await db.collection("emails").doc(emailId).update({
        isReplied: true,
        repliedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log(`Auto reply sent successfully for email ${emailId}`);
    } catch (error) {
      console.error("Error in processAutoReply:", error);
      // Không throw để tránh retry liên tục
    }
  }
);
