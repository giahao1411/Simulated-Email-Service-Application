// eslint-disable-next-line object-curly-spacing
const { PubSub } = require("@google-cloud/pubsub");
const pubsub = new PubSub();

module.exports = pubsub;
