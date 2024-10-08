# Monorepo in Golang with Bazel

1. Install [bazel](https://bazel.build/install)
2. Install [gazelle](https://github.com/bazelbuild/bazel-gazelle?tab=readme-ov-file#running-gazelle-with-go)
3. Run the following command:

   ```bash
   $ bazel run //:gazelle-update-repos
   ```

   This command will regenerate the `go.work.bzl` file.

4. Run the following command:

   ```bash
   $ bazel run //:gazelle
   ```

   This command will generate the `BUILD.bazel` files.

5. Run the following command:

   ```bash
   $ bazel build //...
   ```

   This command will build all the services.

6. Run the following command:

   ```bash
   $ bazel test //...
   ```

   This command will run all the tests.
