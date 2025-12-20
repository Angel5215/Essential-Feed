
# Image Feed Feature

## Load Feed From Cache Use Case

**Data**:

- Max age (7 days)

**Primary course**:

1. Execute "Load Image Feed" command with above data.
2. System fetches feed data from cache. 
3. System validates cache is less than seven days old.
4. System creates image feed from cached data.
5. System delivers image feed. 

**Error course (sad path)**:

1. System delivers error.

**Expired cache course (sad path)**:

1. System deletes cache.
2. System delivers no feed images.

**No cache course (sad path)**:

1. System delivers no feed images.
