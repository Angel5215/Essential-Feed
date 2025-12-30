
# Image Feed Feature

## Validate Feed Cache Use Case

**Data**:

- Max age (7 days)

**Primary course**:

1. Execute "Validate Cache" command with above data.
2. System retrieves feed data from cache. 
3. System validates cache is less than seven days old. 

**Retrieval error course (sad path)**:

1. System deletes cache..

**Expired cache course (sad path)**:

1. System deletes cache.
