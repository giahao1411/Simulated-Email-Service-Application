const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { db, messaging } = require("../firebase");

exports.notifyNewEmail = onDocumentCreated(
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

      console.log(`Processing notification for email ${emailId}`);

      // Lấy thông tin email
      const from = emailData?.from;
      const subject = emailData?.subject || "Không có chủ đề";
      const to = emailData?.to || [];
      const cc = emailData?.cc || [];
      const bcc = emailData?.bcc || [];

      // Bỏ qua nếu là auto reply để tránh spam notification
      if (emailData?.isAutoReply) {
        console.log("Skipping notification for auto reply");
        return;
      }

      // Tập hợp tất cả người nhận
      const recipients = [...to, ...cc, ...bcc];

      if (recipients.length === 0) {
        console.log("No recipients found");
        return;
      }

      console.log(`Found ${recipients.length} recipients`);

      // Lấy FCM tokens của người nhận (giới hạn 10 để tránh vượt quá limit)
      const tokens = [];
      const recipientBatch = recipients.slice(0, 10); // Firestore "in" query giới hạn 10

      try {
        const snapshot = await db
          .collection("user_tokens")
          .where("email", "in", recipientBatch)
          .get();

        snapshot.forEach((doc) => {
          const tokenData = doc.data();
          if (tokenData.token) {
            tokens.push(tokenData.token);
          }
        });

        console.log(`Found ${tokens.length} FCM tokens`);
      } catch (error) {
        console.error("Error getting FCM tokens:", error);
        return;
      }

      if (tokens.length === 0) {
        console.log("No FCM tokens found");
        return;
      }

      // Tạo payload notification
      const payload = {
        notification: {
          title: "📧 Email mới",
          body: `Từ ${from}: ${subject}`,
          icon: "https://img.icons8.com/fluency/48/email.png",
        },
        data: {
          emailId: emailId,
          from: from,
          subject: subject,
          type: "new_email",
        },
        android: {
          notification: {
            channelId: "email_notifications",
            priority: "high",
          },
        },
        apns: {
          payload: {
            aps: {
              badge: 1,
              sound: "default",
            },
          },
        },
      };

      // Gửi notification
      const response = await messaging.sendMulticast({
        tokens,
        ...payload,
      });

      console.log(
        `Notification sent successfully. Success: ${response.successCount}, Failed: ${response.failureCount}`
      );

      // Log failed tokens để debug
      if (response.failureCount > 0) {
        response.responses.forEach((resp, idx) => {
          if (!resp.success) {
            console.error(`Failed to send to token ${idx}:`, resp.error);
          }
        });
      }
    } catch (error) {
      console.error("Error in notifyNewEmail:", error);
      // Không throw error để tránh retry liên tục
    }
  }
);
