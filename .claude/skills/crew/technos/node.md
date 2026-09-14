# node — Node.js HTTP service

> Load when: the change touches `*.ts` or `*.js` under a `package.json` with no `angular.json` above it, whose dependencies include `express`, `fastify`, `koa`, `hono` or `@nestjs/core`. Last watch: — · Target: Node 20 LTS

## MUST

- No framework-specific rule yet — the rules this stack needs today are the BFF pattern and the shared practices, both loaded by context

## Not here

- Aggregation, timeouts, tokens, correlation → `references/bp-bff.md`
- Shape of the HTTP contract → `references/bp-api-rest.md`
- Practices every stack shares → `references/bp-code.md`
