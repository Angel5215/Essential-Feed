# Image Feed Feature

## Load Feed Image Data From Cache Use Case


**Data**:

- URL

**Primary course (happy path)**:

1. Execute "Load Image Data" command with above data.
2. System retrieves data from the cache.
3. System delivers cached image data.

**Cancel course**:

1. System does not deliver image data nor error.

**Retrieval error course (sad path)**:

1. System delivers error.

**Empty cache course (sad path)**:

1. System delivers not found error.
