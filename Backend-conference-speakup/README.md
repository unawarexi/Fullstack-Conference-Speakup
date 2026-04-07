prisma:query SELECT 1
5:55:33 PM [INFO] [Server] PostgreSQL connected
5:55:33 PM [INFO] [Redis] Redis [main] connected
5:55:33 PM [INFO] [Redis] Redis [subscriber] connected
5:55:34 PM [SUCCESS] [Redis] Redis [main] ready
5:55:34 PM [SUCCESS] [Redis] Redis [subscriber] ready
5:55:34 PM [SUCCESS] [Redis] Redis initialized (main + subscriber)
5:55:34 PM [INFO] [Server] Redis connected
{"level":"WARN","timestamp":"2026-04-07T16:55:34.323Z","logger":"kafkajs","message":"KafkaJS v2.0.0 switched default partitioner. To retain the same partitioning behavior as in previous versions, create the producer with the option \"createPartitioner: Partitioners.LegacyPartitioner\". See the migration guide at https://kafka.js.org/docs/migration-guide-v2.0.0#producer-new-default-partitioner for details. Silence this warning by setting the environment variable \"KAFKAJS_NO_PARTITIONER_WARNING=1\""}
(node:42161) TimeoutNegativeWarning: -1775580934349 is a negative number.
Timeout duration was set to 1.
5:55:34 PM [SUCCESS] [Kafka] Kafka producer connected {"brokers":["localhost:9092"],"clientId":"speakup-api"}
5:55:34 PM [INFO] [Server] Kafka connected
5:55:34 PM [SUCCESS] [BullMQ] BullMQ queues initialized {"queues":["EMAIL","NOTIFICATION","RECORDING","ANALYTICS","CLEANUP"]}
5:55:34 PM [SUCCESS] [BullMQ] BullMQ queues initialized {"queues":["EMAIL","NOTIFICATION","RECORDING","ANALYTICS","CLEANUP"]}
5:55:34 PM [INFO] [BullMQ] Worker registered: speakup-email
5:55:34 PM [INFO] [BullMQ] Worker registered: speakup-notification
5:55:34 PM [SUCCESS] [Workers] All workers started
5:55:34 PM [INFO] [Server] BullMQ queues & workers initialized
5:55:34 PM [INFO] [WebSocket] Socket.IO Redis adapter attached
5:55:34 PM [SUCCESS] [WebSocket] WebSocket server initialized
5:55:34 PM [INFO] [Server] WebSocket initialized
5:55:34 PM [WARN] [LiveKit] LiveKit not configured — missing LIVEKIT_HOST, API_KEY, or API_SECRET
5:55:34 PM [SUCCESS] [Billing] Stripe initialized
5:55:34 PM [INFO] [Server] LiveKit & Stripe initialized
5:55:34 PM [SUCCESS] [Mailer] Mailer initialized {"host":"smtp.gmail.com","port":465}
5:55:34 PM [INFO] [Server] ========================================================
5:55:34 PM [INFO] [Server]   SPEAKUP BACKEND SERVER
5:55:34 PM [INFO] [Server] ========================================================
5:55:34 PM [INFO] [Server]   Environment : development
5:55:34 PM [INFO] [Server]   Port        : 3000
5:55:34 PM [INFO] [Server]   API         : /api/v1
5:55:34 PM [INFO] [Server]   Health      : http://localhost:3000/health
5:55:34 PM [INFO] [Server]   Metrics     : http://localhost:3000/metrics
5:55:34 PM [INFO] [Server] ========================================================
IMPORTANT! Eviction policy is volatile-lru. It should be "noeviction"
IMPORTANT! Eviction policy is volatile-lru. It should be "noeviction"
IMPORTANT! Eviction policy is volatile-lru. It should be "noeviction"
IMPORTANT! Eviction policy is volatile-lru. It should be "noeviction"
IMPORTANT! Eviction policy is volatile-lru. It should be "noeviction"
IMPORTANT! Eviction policy is volatile-lru. It should be "noeviction"
IMPORTANT! Eviction policy is volatile-lru. It should be "noeviction"
IMPORTANT! Eviction policy is volatile-lru. It should be "noeviction"
IMPORTANT! Eviction policy is volatile-lru. It should be "noeviction"
IMPORTANT! Eviction policy is volatile-lru. It should be "noeviction"
IMPORTANT! Eviction policy is volatile-lru. It should be "noeviction"
IMPORTANT! Eviction policy is volatile-lru. It should be "noeviction"
IMPORTANT! Eviction policy is volatile-lru. It should be "noeviction"
IMPORTANT! Eviction policy is volatile-lru. It should be "noeviction"
^C5:55:40 PM [INFO] [Server] SIGINT received — shutting down...
5:55:40 PM [INFO] [Server] HTTP server closed
[Prisma] Disconnected successfully
5:55:40 PM [INFO] [Server] Database disconnected
make: *** [dev] Interrupt: 2
