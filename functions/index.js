const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { PubSub } = require("@google-cloud/pubsub");

admin.initializeApp();
const pubsub = new PubSub();
const db = admin.firestore();

// set auto-reply sau 5 phút
exports.scheduleAutoReply = functions.firestore
    .document("emails/{emailId}")
    .onCreate(async (snap, context) => {
        const emailData = snap.data();
        const emailId = context.params.emailId;

        if (
            !emailData ||
            !emailData.from ||
            !emailData.to ||
            !Array.isArray(emailData.to) ||
            emailData.to.length === 0
        ) {
            console.log("Dữ liệu email không hợp lệ:", emailData);
            return null;
        }

        if (emailData.isAutoReply) {
            console.log(
                "Email này là auto-reply, không kích hoạt thêm:",
                emailId
            );
            return null;
        }

        const senderEmail = emailData.from;
        const recipientEmail = emailData.to[0];
        console.log(
            "Lên lịch auto-reply từ:",
            recipientEmail,
            "đến:",
            senderEmail
        );

        try {
            if (emailData.isReplied) {
                console.log("Email đã được trả lời tự động:", emailId);
                return null;
            }

            if (emailData.read) {
                console.log(
                    "Email đã được đọc, không gửi auto-reply:",
                    emailId
                );
                return null;
            }

            const replySnapshot = await db
                .collection("emails")
                .where("from", "==", recipientEmail)
                .where("to", "array-contains", senderEmail)
                .where("isAutoReply", "==", true)
                .limit(1)
                .get();

            if (!replySnapshot.empty) {
                console.log(
                    "Đã có auto-reply từ",
                    recipientEmail,
                    "đến",
                    senderEmail,
                    "trước đó, không gửi thêm"
                );
                return null;
            }

            const userSnapshot = await db
                .collection("users")
                .where("email", "==", recipientEmail)
                .limit(1)
                .get();

            const delaySeconds = userSnapshot.empty
                ? 5 * 60
                : (userSnapshot.docs[0].data().autoReplyTime || 5) * 60;
            const topicName = "send-auto-reply";
            const messageData = {
                emailId,
                from: recipientEmail,
                to: senderEmail,
                subject: emailData.subject || "Không có chủ đề",
                autoReplyMessage:
                    "Cảm ơn bạn, tôi sẽ trả lời bạn sớm nhất có thể.",
            };

            await pubsub.topic(topicName).publishMessage({
                json: messageData,
                attributes: { delaySeconds: delaySeconds.toString() },
            });

            console.log(
                `Đã lên lịch auto-reply từ ${recipientEmail} đến ${senderEmail}` +
                    ` sau ${delaySeconds / 60} phút`
            );
        } catch (error) {
            console.error("Lỗi khi lên lịch auto-reply:", error);
        }
        return null;
    });

// xử lý auto-reply khi nhận được tin nhắn từ Pub/Sub
exports.processAutoReply = functions.pubsub
    .topic("send-auto-reply")
    .onPublish(async (message) => {
        const { emailId, from, to, subject, autoReplyMessage } = message.json;

        if (!emailId || !from || !to) {
            console.log("Dữ liệu message không hợp lệ:", message.json);
            return null;
        }

        console.log(`Bắt đầu xử lý auto-reply từ ${from} đến ${to}`);

        try {
            const emailDoc = await db.collection("emails").doc(emailId).get();

            if (!emailDoc.exists) {
                console.log("Email không còn tồn tại:", emailId);
                return null;
            }

            const emailData = emailDoc.data();
            if (emailData.isReplied) {
                console.log("Email đã được trả lời tự động:", emailId);
                return null;
            }

            await db.collection("emails").add({
                from: from,
                to: [to],
                subject: `Tự động trả lời: ${subject}`,
                body: autoReplyMessage,
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
                isReplied: false,
                read: false,
                starred: false,
                labels: [],
                isAutoReply: true,
            });

            console.log(
                "Auto-reply đã được thêm vào Firestore từ:",
                from,
                "đến:",
                to
            );

            await db
                .collection("emails")
                .doc(emailId)
                .update({ isReplied: true });
        } catch (error) {
            console.error("Lỗi khi xử lý auto-reply:", error);
        }
        return null;
    });

exports.notifyNewEmail = functions.firestore
    .document("/emails/{emailId}")
    .onCreate(async (snap, context) => {
        const email = snap.data();
        const recipients = [
            ...(email.to || []),
            ...(email.cc || []),
            ...(email.bcc || []),
        ];

        // get token for each recipient
        const tokens = [];
        const userTokensSnapshot = await admin
            .firestore()
            .collection("user_tokens")
            .where("email", "in", recipients.slice(0, 10)) // firestore has a limit of 10 in 'in' queries
            .get();

        userTokensSnapshot.forEach((doc) => {
            tokens.push(doc.data().token);
        });

        if (tokens.length === 0) {
            console.log("No tokens found for recipients:", recipients);
            return null;
        }

        const payload = {
            notification: {
                title: "Email mới",
                body: `Từ ${email.from}: ${email.subject || "Không có chủ đề"}`,
            },
            data: {
                emailId: snap.id,
            },
        };

        try {
            await admin.messagnig().sendMulticast({ tokens, ...payload });
            console.log("Notification sent successfully to:", tokens);
        } catch (error) {
            console.error("Error sending notification:", error);
        }

        return null;
    });
