**Build Artifacts vs. Pipeline Artifacts in Azure Pipelines**

- **Build Artifacts**:
  - Managed by `PublishBuildArtifacts` and `DownloadBuildArtifacts` tasks.
  - Older, legacy system designed for build outputs in Azure DevOps.
  - Stored in general-purpose Azure DevOps storage, with more metadata overhead.
  - Slower uploads/downloads due to sequential processing and legacy compatibility.
  - Best for compatibility with older release pipelines or external tools.
  - Example: Uploading a `.nupkg` to a generic container for manual download.

- **Pipeline Artifacts**:
  - Managed by `PublishPipelineArtifact` and `DownloadPipelineArtifact` tasks.
  - Modern, optimized for Azure Pipelines, introduced ~2019.
  - Stored in cloud-based storage with minimal overhead and parallelized transfers.
  - Faster uploads/downloads (20-50% improvement for large files).
  - Recommended for most pipelines, especially for performance-critical workflows.
  - Example: Uploading a `.nupkg` for use in downstream pipeline jobs or stages.

**Key Difference**: Pipeline artifacts are faster and more efficient due to optimized storage and transfer protocols, while build artifacts are slower but support legacy scenarios. Use pipeline artifacts unless compatibility with older systems is required.