# Monorepo in Golang with Earthly

1. Install [Earthly](https://earthly.dev/get-earthly)
2. Run the following commands:

   ```bash
   $ earthly +compile
   $ earthly +test
   $ earthly +lint
   $ earthly +docker
   $ earthly +release
   ```

3. The following results will be produced:

   - `date-service:v0.0.1` - Docker image for **date-service**;
   - `time-service:v0.0.1` - Docker image for **time-service**;
   - `./artifacts/lint` - linter reports;
   - `./artifacts/tests` - test reports;
   - `./artifacts/coverage` - test coverage reports;
