
# Image Feed Feature

## Load Feed Fallback (Cache) Use Case

**Data**:

- Max age

**Primary course**:

1. Execute "Retrieve Feed Items" command with above data.
2. System fetches feed data from cache. 
3. System creates feed items from cached data.
4. System delivers feed items. 

**No cache course (sad path)**:

1. System delivers no feed items.
