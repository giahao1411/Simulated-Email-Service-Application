const { onRequest } = require("firebase-functions/v2/https");
const { db, admin } = require("../firebase");

const processAutoReply = onRequest(async (req, res) => {
  try {
    const messageData = req.body;
    const { emailId, from, to, subject, autoReplyMessage } = messageData;

    console.log(`Processing auto reply for email ${emailId}`);

    if (!emailId || !from || !to) {
      console.log("Missing required fields");
      return res.status(400).send("Missing required fields");
    }

    const emailDoc = await db.collection("emails").doc(emailId).get();

    if (!emailDoc.exists) {
      console.log(`Original email ${emailId} not found`);
      return res.status(404).send("Email not found");
    }

    const emailData = emailDoc.data();
    if (emailData.isReplied) {
      console.log(`Email ${emailId} already replied`);
      return res.status(200).send("Already replied");
    }

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

    await db.collection("emails").add(autoReplyData);

    await db.collection("emails").doc(emailId).update({
      isReplied: true,
      repliedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log(`Auto reply sent successfully for email ${emailId}`);
    res.status(200).send("Auto reply sent successfully");
  } catch (error) {
    console.error("Error in processAutoReply:", error);
    res.status(500).send("Error processing auto reply");
  }
});

module.exports = { processAutoReply };
