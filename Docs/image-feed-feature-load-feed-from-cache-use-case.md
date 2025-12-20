
# Image Feed Feature

## Load Feed From Cache Use Case

**Data**:

- Max age (7 days)

**Primary course**:

1. Execute "Load Feed Items" command with above data.
2. System fetches feed data from cache. 
3. System validates cache is less than seven days old.
4. System creates feed items from cached data.
5. System delivers feed items. 

**Error course (sad path)**:

1. System delivers error.

**Expired cache course (sad path)**:

1. System deletes cache.
2. System delivers no feed items.

**No cache course (sad path)**:

1. System delivers no feed items.
