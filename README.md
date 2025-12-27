# Essential Feed

[![ci-macOS](https://github.com/Angel5215/Essential-Feed/actions/workflows/ci-macOS.yml/badge.svg?branch=main)](https://github.com/Angel5215/Essential-Feed/actions/workflows/ci-macOS.yml)
[![ci-iOS](https://github.com/Angel5215/Essential-Feed/actions/workflows/ci-iOS.yml/badge.svg?branch=main)](https://github.com/Angel5215/Essential-Feed/actions/workflows/ci-iOS.yml)


Repository created to keep track of the iOS Lead Essentials training program. This repository keeps track of all the lectures in the program with some small twists - using Swift Package Manager to create the modules (frameworks) and using some modern technologies for practice (Swift Testing instead of XCTest). The overall result should be equivalent but it serves to practice the TDD approach while learning new technologies at the same time.

## Requirements

### Image Feed Feature

- [Story: Customer requests to see their image feed][bdd-specs]
- Use cases:
  - [Load Feed From Remote Use Case][load-feed-from-remote-use-case]
  - [Load Feed From Cache Use Case][load-feed-from-cache-use-case]
  - [Cache Feed Use Case][cache-feed-use-case]
  - [Validate Feed Cache Use Case][validate-feed-cache-use-case]
- [API model][api-model]

<!-- Start Link section -->
[bdd-specs]: Docs/image-feed-feature-story.md
[api-model]: Docs/image-feed-feature-api-model.md
[load-feed-from-remote-use-case]: Docs/image-feed-feature-load-feed-from-remote-use-case.md
[load-feed-from-cache-use-case]: Docs/image-feed-feature-load-feed-from-cache-use-case.md
[cache-feed-use-case]: Docs/image-feed-feature-cache-feed-use-case.md
[validate-feed-cache-use-case]: Docs/image-feed-feature-validate-feed-cache-use-case.md
<!-- End Link section -->

## Architecture

<img src="Docs/architecture.png" height="500px" alt="Proposed architecture diagram"/>

## Flowchart

<img src="Docs/flow-diagram.png" height="500px" alt="Proposed architecture diagram"/>

## Requirements

1. [Stories and Use Cases (Image Feed Feature)](Docs/specs-image-feed-feature.md)
2. [Image Feed Feature API specs](Docs/specs-api-model.md)
