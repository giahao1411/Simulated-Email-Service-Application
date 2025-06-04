const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { db } = require("../firebase");
const pubsub = require("../utils/pubsub");

exports.scheduleAutoReply = onDocumentCreated(
  {
    document: "emails/{emailId}",
    region: "us-central1",
    memory: "512MiB", // Tăng memory để khởi động ổn định
    timeoutSeconds: 120, // Tăng timeout cho việc khởi động
    maxInstances: 1, // Chỉ 1 instance để miễn phí
    concurrency: 1, // 1 request/instance
    minInstances: 0, // Không giữ instance chạy liên tục
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

      // Lấy dữ liệu từ document
      const from = emailData?.from;
      const to = emailData?.to || [];

      if (!from || to.length === 0) {
        console.log("Missing from or to email");
        return;
      }

      const { isAutoReply, isReplied, read } = emailData;

      // Bỏ qua nếu là auto reply, đã reply, hoặc đã đọc
      if (isAutoReply || isReplied || read) {
        console.log("Email is auto reply, already replied, or read");
        return;
      }

      const senderEmail = from;
      const recipientEmail = to[0];

      // Kiểm tra đã có auto reply chưa để tránh spam
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

      // Lấy thời gian delay từ user settings (mặc định 5 phút)
      let delaySeconds = 5 * 60; // 5 phút mặc định

      try {
        const userSnapshot = await db
          .collection("users")
          .where("email", "==", recipientEmail)
          .limit(1)
          .get();

        if (!userSnapshot.empty) {
          const userData = userSnapshot.docs[0].data();
          delaySeconds = (userData.autoReplyTime || 5) * 60;
        }
      } catch (error) {
        console.log("Error getting user settings, using default:", error);
      }

      const messageData = {
        emailId,
        from: recipientEmail,
        to: senderEmail,
        subject: emailData?.subject || "Không có chủ đề",
        autoReplyMessage:
          "Cảm ơn bạn đã gửi email. Tôi sẽ trả lời bạn sớm nhất có thể.",
      };

      // Gửi message đến PubSub topic
      await pubsub.topic("send-auto-reply").publishMessage({
        json: messageData,
        attributes: {
          delaySeconds: delaySeconds.toString(),
        },
      });

      console.log(
        `Scheduled auto reply for email ${emailId} with delay ${delaySeconds}s`
      );
    } catch (error) {
      console.error("Error in scheduleAutoReply:", error);
      // Không throw error để tránh retry không cần thiết
    }
  }
);
