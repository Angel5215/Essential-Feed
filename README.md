# Essential Feed

[![ci](https://github.com/Angel5215/Essential-Feed/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/Angel5215/Essential-Feed/actions/workflows/ci.yml)


Repository created to keep track of the iOS Lead Essentials training program. This repository keeps track of all the lectures in the program with some small twists - using Swift Package Manager to create the modules (frameworks) and using some modern technologies for practice (Swift Testing instead of XCTest). The overall result should be equivalent but it serves to practice the TDD approach while learning new technologies at the same time.

## Requirements

### Image Feed Feature

- [Story: Customer requests to see their image feed][bdd-specs]
- Use cases:
  - [Load Feed Use Case][load-feed-use-case]
  - [Load Feed Fallback Use Case][load-feed-fallback-use-case]
  - [Save Feed Items Use Case][save-feed-items-use-case]
- [API model][api-model]

<!-- Start Link section -->
[bdd-specs]: Docs/image-feed-feature-story.md
[api-model]: Docs/image-feed-feature-api-model.md
[load-feed-use-case]: Docs/image-feed-feature-load-feed-use-case.md
[load-feed-fallback-use-case]: Docs/image-feed-feature-load-feed-fallback-use-case.md
[save-feed-items-use-case]: Docs/image-feed-feature-save-feed-items-use-case.md
<!-- End Link section -->

## Architecture

<img src="Docs/architecture.png" height="500px" alt="Proposed architecture diagram"/>

## Flowchart

<img src="Docs/flow-diagram.png" height="500px" alt="Proposed architecture diagram"/>

## Requirements

1. [Stories and Use Cases (Image Feed Feature)](Docs/specs-image-feed-feature.md)
2. [Image Feed Feature API specs](Docs/specs-api-model.md)
