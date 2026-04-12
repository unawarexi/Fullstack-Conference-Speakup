 [ERROR] [Server] Failed to start server {}
KafkaJSProtocolError: This server does not host this topic-partition
    at createErrorFromCode (/Users/mac/Desktop/MY/Fullstack-Conference-Speakup/Backend-conference-speakup/node_modules/kafkajs/src/protocol/error.js:581:10)
    at Object.parse (/Users/mac/Desktop/MY/Fullstack-Conference-Speakup/Backend-conference-speakup/node_modules/kafkajs/src/protocol/requests/metadata/v0/response.js:55:11)
    at Connection.send (/Users/mac/Desktop/MY/Fullstack-Conference-Speakup/Backend-conference-speakup/node_modules/kafkajs/src/network/connection.js:433:35)
    at process.processTicksAndRejections (node:internal/process/task_queues:103:5)
    at async [private:Broker:sendRequest] (/Users/mac/Desktop/MY/Fullstack-Conference-Speakup/Backend-conference-speakup/node_modules/kafkajs/src/broker/index.js:904:14)
    at async Broker.metadata (/Users/mac/Desktop/MY/Fullstack-Conference-Speakup/Backend-conference-speakup/node_modules/kafkajs/src/broker/index.js:177:12)
    at async /Users/mac/Desktop/MY/Fullstack-Conference-Speakup/Backend-conference-speakup/node_modules/kafkajs/src/cluster/brokerPool.js:158:25
    at async /Users/mac/Desktop/MY/Fullstack-Conference-Speakup/Backend-conference-speakup/node_modules/kafkajs/src/cluster/index.js:111:14
    at async Cluster.refreshMetadata (/Users/mac/Desktop/MY/Fullstack-Conference-Speakup/Backend-conference-speakup/node_modules/kafkajs/src/cluster/index.js:172:5)
    at async Cluster.addMultipleTargetTopics (/Users/mac/Desktop/MY/Fullstack-Conference-Speakup/Backend-conference-speakup/node_modules/kafkajs/src/cluster/index.js:230:11)
[nodemon] app crashed - waiting for file changes before starting...
