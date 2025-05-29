const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { db } = require("../firebase");
const pubsub = require("../utils/pubsub");

exports.scheduleAutoReply = onDocumentCreated(
    {
        document: "emails/{emailId}",
        region: "us-central1", // hoặc region phù hợp
        memory: "256MiB", // tùy chọn
        timeoutSeconds: 60, // tùy chọn
    },
    async (event) => {
        const snap = event.data;
        if (!snap) return;

        const emailData = snap.value?.fields;
        const emailId = event.params.emailId;

        const getValue = (field) => {
            if (!field) return undefined;
            const type = Object.keys(field)[0];
            return field[type];
        };

        const from = getValue(emailData?.from);
        const to = emailData?.to?.arrayValue?.values?.map(getValue) || [];

        if (!from || to.length === 0) return;

        const isAutoReply = getValue(emailData?.isAutoReply);
        const isReplied = getValue(emailData?.isReplied);
        const read = getValue(emailData?.read);

        if (isAutoReply || isReplied || read) return;

        const senderEmail = from;
        const recipientEmail = to[0];

        // Tránh trả lời tự động nhiều lần
        const replySnapshot = await db
            .collection("emails")
            .where("from", "==", recipientEmail)
            .where("to", "array-contains", senderEmail)
            .where("isAutoReply", "==", true)
            .limit(1)
            .get();

        if (!replySnapshot.empty) return;

        // Lấy thời gian delay từ user
        const userSnapshot = await db
            .collection("users")
            .where("email", "==", recipientEmail)
            .limit(1)
            .get();

        const delaySeconds = userSnapshot.empty
            ? 5 * 60
            : (userSnapshot.docs[0].data().autoReplyTime || 5) * 60;

        const subject = getValue(emailData?.subject) || "Không có chủ đề";

        const messageData = {
            emailId,
            from: recipientEmail,
            to: senderEmail,
            subject,
            autoReplyMessage: "Cảm ơn bạn, tôi sẽ trả lời bạn sớm nhất có thể.",
        };

        // Gửi đến PubSub topic với delay
        await pubsub.topic("send-auto-reply").publishMessage({
            json: messageData,
            attributes: {
                delaySeconds: delaySeconds.toString(),
            },
        });
    }
);
