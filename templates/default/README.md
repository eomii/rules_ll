# The `rules_ll` template

To get started adjust the `rules_ll` commit in `MODULE.bazel`.

This template ships with the `ll up` command which spins up a local NativeLink
cluster for experimentation with remote execution.

You can get the gateways like this:

```bash
export CACHE=$(kubectl get gtw cache -o=jsonpath='{.status.addresses[0].value}')
export SCHEDULER=$(kubectl get gtw scheduler -o=jsonpath='{.status.addresses[0].value}')

bazel build \
    --remote_instance_name=main \
    --remote_cache=grpc://$CACHE:50051 \
    --remote_executor=grpc://$SCHEDULER:50052 \
    ...
```
