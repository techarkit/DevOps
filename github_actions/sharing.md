# Guide for Sharing Variables Within Jobs in GitHub Actions

GitHub Actions workflows often require passing data between jobs. Since each job runs in a fresh environment, you need explicit mechanisms to share variables and data. Here's a comprehensive guide to the different approaches:

## 1. Using Job Outputs

The most common way to share simple values between jobs in the same workflow.

### How to Set an Output in One Job:
```yaml
jobs:
  job1:
    runs-on: ubuntu-latest
    outputs:
      output1: ${{ steps.step1.outputs.myoutput }}
    steps:
      - id: step1
        run: echo "myoutput=value" >> $GITHUB_OUTPUT
```

### How to Use in Another Job:
```yaml
  job2:
    needs: job1
    runs-on: ubuntu-latest
    steps:
      - run: echo ${{ needs.job1.outputs.output1 }}
```

## 2. Using Artifacts for Complex Data

For sharing files or larger data between jobs.

### Uploading Artifacts:
```yaml
jobs:
  job1:
    runs-on: ubuntu-latest
    steps:
      - run: echo "complex data" > data.txt
      - uses: actions/upload-artifact@v3
        with:
          name: shared-data
          path: data.txt
```

### Downloading Artifacts:
```yaml
  job2:
    needs: job1
    runs-on: ubuntu-latest
    steps:
      - uses: actions/download-artifact@v3
        with:
          name: shared-data
      - run: cat data.txt
```

## 3. Using Environment Variables

For sharing variables that multiple jobs need to reference.

### Setting in Workflow:
```yaml
env:
  SHARED_VAR: "value"
```

### Using in Steps:
```yaml
steps:
  - run: echo ${{ env.SHARED_VAR }}
```

## 4. Using Cache for Repeated Data

For sharing data that doesn't change often between workflow runs.

### Saving to Cache:
```yaml
steps:
  - uses: actions/cache@v3
    id: cache
    with:
      path: path/to/dependencies
      key: ${{ runner.os }}-${{ hashFiles('**/lockfiles') }}
```

### Restoring from Cache:
```yaml
steps:
  - uses: actions/cache@v3
    with:
      path: path/to/dependencies
      key: ${{ runner.os }}-${{ hashFiles('**/lockfiles') }}
```

## Best Practices

1. **Use outputs for simple values** - Most efficient for small data
2. **Use artifacts for files/complex data** - When you need to pass entire files
3. **Minimize shared data** - Only share what's absolutely necessary
4. **Consider security** - Never share secrets through outputs or artifacts
5. **Document shared variables** - Make it clear what's being shared and why

## Example Workflow

```yaml
name: Shared Variables Example

on: [push]

jobs:
  setup:
    runs-on: ubuntu-latest
    outputs:
      build_id: ${{ steps.setid.outputs.build_id }}
    steps:
      - id: setid
        run: echo "build_id=$(date +%s)" >> $GITHUB_OUTPUT

  build:
    needs: setup
    runs-on: ubuntu-latest
    steps:
      - run: echo "Building with ID ${{ needs.setup.outputs.build_id }}"
      - run: echo "content" > build-result.txt
      - uses: actions/upload-artifact@v3
        with:
          name: build-result
          path: build-result.txt

  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - uses: actions/download-artifact@v3
        with:
          name: build-result
      - run: cat build-result.txt
      - run: echo "Deploying build ${{ needs.setup.outputs.build_id }}"
```

Remember that jobs run on different runners, so direct memory sharing isn't possible - you must always explicitly pass data between jobs using one of these methods.