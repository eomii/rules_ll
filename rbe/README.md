<!-- vale alex.ProfanityUnlikely = NO -->
# Remote execution toolchains

Generated toolchains for `rules_java` and `rules_cc` compatible with the remote
execution container.

## Generating the sources

Regenerating the toolchains requires a local container registry:

```bash
docker run -d -p 5000:5000 --restart=always --name registry registry:2
```

From the root directory of `rules_ll`, invoke the `ll rbe` tool to build the
remote execution image, copy it to the local container registry and regenerate
the toolchain configurations:
<!-- vale alex.ProfanityUnlikely = NO -->

```bash
ll rbe
```

To stop the local container registry:

```bash
docker container stop registry && docker container rm -v registry
```
