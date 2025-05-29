const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { db, messaging } = require("../firebase");

exports.notifyNewEmail = onDocumentCreated(
    {
        document: "emails/{emailId}",
        region: "us-central1", // hoặc region phù hợp với project của bạn
        memory: "256MiB",
        timeoutSeconds: 60,
    },
    async (event) => {
        const snap = event.data;
        if (!snap) return;

        const emailData = snap.value?.fields;

        // Helper: convert Firestore Proto fields to JS values
        const getValue = (field) => {
            if (!field) return undefined;
            return Object.values(field)[0];
        };

        const from = getValue(emailData?.from);
        const subject = getValue(emailData?.subject) || "Không có chủ đề";

        const to = emailData?.to?.arrayValue?.values?.map(getValue) || [];
        const cc = emailData?.cc?.arrayValue?.values?.map(getValue) || [];
        const bcc = emailData?.bcc?.arrayValue?.values?.map(getValue) || [];

        const recipients = [...to, ...cc, ...bcc];

        if (recipients.length === 0) return;

        const tokens = [];

        const snapshot = await db
            .collection("user_tokens")
            .where("email", "in", recipients.slice(0, 10)) // Firestore "in" query giới hạn 10 phần tử
            .get();

        snapshot.forEach((doc) => {
            const token = doc.data().token;
            if (token) tokens.push(token);
        });

        if (tokens.length === 0) return;

        const payload = {
            notification: {
                title: "Email mới",
                body: `Từ ${from}: ${subject}`,
            },
            data: {
                emailId: event.params.emailId,
            },
        };

        try {
            await messaging.sendMulticast({ tokens, ...payload });
        } catch (err) {
            console.error("Send notify error:", err);
        }
    }
);
