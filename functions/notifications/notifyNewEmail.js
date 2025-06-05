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
                console.log("Không có dữ liệu tài liệu");
                return;
            }

            const emailData = snap.data();
            const emailId = event.params.emailId;

            console.log(`Đang xử lý thông báo cho email ${emailId}`);

            const from = emailData?.from;
            const subject = emailData?.subject || "Không có chủ đề";
            const to = emailData?.to || [];
            const cc = emailData?.cc || [];
            const bcc = emailData?.bcc || [];

            if (emailData?.isAutoReply) {
                console.log("Bỏ qua thông báo cho email tự động");
                return;
            }

            const recipients = [...to, ...cc, ...bcc];
            if (recipients.length === 0) {
                console.log("Không tìm thấy người nhận");
                return;
            }

            console.log(`Tìm thấy ${recipients.length} người nhận`);

            const tokens = [];
            const recipientBatch = recipients.slice(0, 10);

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

                console.log(`Tìm thấy ${tokens.length} FCM tokens`);
            } catch (error) {
                console.error("Lỗi khi lấy FCM tokens:", error);
                return;
            }

            if (tokens.length === 0) {
                console.log("Không tìm thấy FCM tokens");
                return;
            }

            const payload = {
                notification: {
                    title: "📧 Email mới",
                    body: `Từ ${from}: ${subject}`,
                },
                data: {
                    emailId: String(emailId),
                    sender: String(from), // Đổi từ 'from' thành 'sender'
                    subject: String(subject),
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

            const sendIndividualNotifications = async (
                tokens,
                payload,
                retries = 3,
                delay = 1000
            ) => {
                const responses = [];
                for (const token of tokens) {
                    for (let attempt = 1; attempt <= retries; attempt++) {
                        try {
                            const singlePayload = { ...payload, token };
                            const response = await messaging.send(
                                singlePayload
                            );
                            responses.push({ success: true, token });
                            console.log(
                                `Gửi thông báo thành công cho token ${token}`
                            );
                            break; // Thoát vòng lặp thử lại nếu gửi thành công
                        } catch (error) {
                            console.error(
                                `Lần thử ${attempt} thất bại cho token ${token}:`,
                                error
                            );
                            if (attempt < retries) {
                                await new Promise((resolve) =>
                                    setTimeout(resolve, delay)
                                );
                                delay *= 2;
                            } else {
                                responses.push({
                                    success: false,
                                    token,
                                    error,
                                });
                                if (
                                    error.code ===
                                        "messaging/invalid-registration-token" ||
                                    error.code ===
                                        "messaging/registration-token-not-registered"
                                ) {
                                    await db
                                        .collection("user_tokens")
                                        .where("token", "==", token)
                                        .get()
                                        .then((snapshot) =>
                                            snapshot.forEach((doc) =>
                                                doc.ref.delete()
                                            )
                                        );
                                    console.log(
                                        `Đã xóa token không hợp lệ: ${token}`
                                    );
                                }
                            }
                        }
                    }
                }
                const successCount = responses.filter((r) => r.success).length;
                const failureCount = responses.length - successCount;
                console.log(
                    `Gửi thông báo thành công. Thành công: ${successCount}, Thất bại: ${failureCount}`
                );
                return responses;
            };

            await sendIndividualNotifications(tokens, payload);
        } catch (error) {
            console.error("Lỗi trong notifyNewEmail:", error);
        }
    }
);
