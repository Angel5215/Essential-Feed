
# Image Feed Feature

## Cache Feed Use Case

**Data**:

- Image Feed

**Primary course (happy path)**:

1. Execute "Save Image Feed" command with above data. 
2. System deletes old cache data.
3. System encodes image feed. 
4. System timestamps the new cache. 
5. System saves new cache date. 
6. System delivers success message.

**Deleting error course (sad path)**:

1. System delivers error.

**Saving error course (sad path)**:

1. System delivers error.
