import fastify from "fastify";
import jsonPatch from "fast-json-patch";
import { AddressInfo } from "net";
import { Map } from "immutable";

////////////////////////////////////////////////////////////////////////////////
// Helpers
////////////////////////////////////////////////////////////////////////////////
/**
 * @TODO: fill with actual logic to fetch namespace
 */
const getNamespace = async () => "I WAS INJECTED AT RUNTIME";

const addNamespace = async (serviceInstance: { [key: string]: any }) => {
  const instanceWithNamespaceTag = Map(serviceInstance)
    .setIn(["spec", "parameters", "tags", "namespace"], await getNamespace())
    .toJS();

  return jsonPatch.compare(serviceInstance, instanceWithNamespaceTag);
};

////////////////////////////////////////////////////////////////////////////////
// Setup / Routes
////////////////////////////////////////////////////////////////////////////////
const server = fastify({ logger: true })
  .get("/", async () => ({
    instructions:
      "Send ServiceInstance JSON to /tag via GET query or POST body and a JSON Patch will be returned."
  }))
  .get("/tag", async (request, reply) => addNamespace(request.query))
  .post("/tag", async (request, response) => addNamespace(request.body));

////////////////////////////////////////////////////////////////////////////////
// Main
////////////////////////////////////////////////////////////////////////////////
const start = async () =>
  server
    .listen(8080, "0.0.0.0")
    .then(() =>
      server.log.info(
        `server listening on ${(server.server.address() as AddressInfo).port}`
      )
    )
    .catch(err => {
      server.log.error(err);
      process.exit(1);
    });

start();
