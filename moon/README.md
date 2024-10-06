# Monorepo in Golang with Moon

1. Install [proto](https://moonrepo.dev/docs/proto/install)
2. Install [moon](https://moonrepo.dev/docs/install)
3. Run the following commands:

   ```bash
   $ moon run :all
   ```

4. The following results will be produced:

   - `artifacts/bin/*` - service binaries;
   - `artifacts/coverage/*.pct` - test coverage percentage;
   - `artifacts/coverage/*.xml` - test coverage reports;
   - `artifacts/images/*.tar` - docker images;
   - `artifacts/images/*.txt` - docker image tags;
   - `artifacts/lint/*` - linter reports;
   - `artifacts/version/*` - version numbers;
