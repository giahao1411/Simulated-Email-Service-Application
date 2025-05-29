const { onMessagePublished } = require("firebase-functions/v2/pubsub");
const { db, admin } = require("../firebase");

exports.processAutoReply = onMessagePublished(
    {
        topic: "send-auto-reply", // khai báo topic
        region: "us-central1", // bắt buộc với Gen 2
        memory: "256MiB", // tùy chọn
        timeoutSeconds: 60, // tùy chọn
    },
    async (event) => {
        const message = event.data?.message;
        if (!message) return;

        const json = message.json || {};
        const { emailId, from, to, subject, autoReplyMessage } = json;

        if (!emailId || !from || !to) return;

        const emailDoc = await db.collection("emails").doc(emailId).get();
        if (!emailDoc.exists || emailDoc.data().isReplied) return;

        await db.collection("emails").add({
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
        });

        await db.collection("emails").doc(emailId).update({ isReplied: true });
    }
);
