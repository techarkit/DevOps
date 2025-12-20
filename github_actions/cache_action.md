# GitHub Cache Action Guide

The `actions/cache` action is a powerful tool in GitHub Actions that allows you to save and restore files (like dependencies or build outputs) between workflow runs, significantly improving performance by avoiding redundant downloads or rebuilds.

## What It Does

The cache action:
- **Saves** specified files/directories at the end of a job
- **Restores** them in future workflow runs when there's a cache hit
- Works like a key-value store where you define what to cache and under what conditions

## Basic Usage

### Restoring Cache
```yaml
steps:
- uses: actions/cache@v3
  with:
    path: |
      path/to/dependencies
      another/path
    key: ${{ runner.os }}-${{ hashFiles('**/lockfile') }}
```

### Automatic Cache Saving
The action automatically saves the cache at the end of the job if a new key was generated.

## Key Features

1. **Key-Based Retrieval**:
   - Cache is retrieved when the exact key matches
   - You can use variables like `runner.os`, `hashFiles`, etc. to create dynamic keys

2. **Restore Keys**:
   - Fallback mechanism when exact key doesn't match
   ```yaml
   with:
     path: node_modules
     key: ${{ runner.os }}-npm-${{ hashFiles('**/package-lock.json') }}
     restore-keys: |
       ${{ runner.os }}-npm-
   ```

3. **Multiple Paths**:
   - Can cache multiple directories/files
   ```yaml
   path: |
     ~/.npm
     ~/.cache
   ```

## Common Use Cases

### Node.js (npm/yarn)
```yaml
- uses: actions/cache@v3
  with:
    path: |
      ~/.npm
      node_modules
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
```

### Python (pip)
```yaml
- uses: actions/cache@v3
  with:
    path: ~/.cache/pip
    key: ${{ runner.os }}-pip-${{ hashFiles('**/requirements.txt') }}
```

### Maven (Java)
```yaml
- uses: actions/cache@v3
  with:
    path: ~/.m2/repository
    key: ${{ runner.os }}-maven-${{ hashFiles('**/pom.xml') }}
```

### Gradle (Java/Kotlin)
```yaml
- uses: actions/cache@v3
  with:
    path: |
      ~/.gradle/caches
      ~/.gradle/wrapper
    key: ${{ runner.os }}-gradle-${{ hashFiles('**/*.gradle*', '**/gradle-wrapper.properties') }}
```

## Cache Limits

- **Maximum size**: 10GB per repository (as of 2023)
- **Eviction policy**: Least Recently Used (LRU) when space is needed
- **Retention**: Caches can be saved for up to 7 days unless accessed

## Best Practices

1. **Use specific keys** - Include OS, dependency versions, and lockfile hashes
2. **Limit cache size** - Only cache what's necessary
3. **Order matters** - Place cache step before dependency installation
4. **Use restore-keys** - For partial matches when exact key isn't found
5. **Clear caches** when dependency structures change significantly

## Example Workflow

```yaml
name: Cached Build

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Cache Node Modules
      uses: actions/cache@v3
      id: npm-cache
      with:
        path: |
          node_modules
          ~/.npm
        key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
        
    - name: Install Dependencies
      if: steps.npm-cache.outputs.cache-hit != 'true'
      run: npm ci
      
    - name: Build
      run: npm run build
```

The cache action can dramatically reduce workflow run times, especially for workflows that frequently install the same dependencies.