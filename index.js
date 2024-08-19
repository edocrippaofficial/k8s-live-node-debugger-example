const Fastify = require('fastify')

const fastify = Fastify({ logger: true })

// Become 'healthy' after 10 seconds
let healthy = false
setTimeout(() => { healthy = true }, 10000)
fastify.get('/health', async (request, reply) => {
  reply.code(healthy ? 200 : 500).send()
})

fastify.get('/', async (request, reply) => {
  return { hello: 'world' }
})

fastify.listen({port: 3000, host: '0.0.0.0'}, (err, address) => {
  if (err) {
    fastify.log.error(err)
    process.exit(1)
  }
})
