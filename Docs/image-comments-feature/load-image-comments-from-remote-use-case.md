# Image Comments Feature

## Load Image Comments From Remote Use Case

**Data**:

- ImageID

**Primary course (happy path)**:

1. Execute "Load Image Comments" command with above data.
2. System loads data from remote service.
3. System validates data.
4. System creates comments from valid data.
5. System delivers comments.

**Invalid data – error course (sad path)**:

1. System delivers invalid data error.

**No connectivity – error course (sad path)**:

1. System delivers connectivity error.
