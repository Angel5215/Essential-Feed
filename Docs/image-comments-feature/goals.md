# Image Comments Feature 

## Goals

1. Display a list of comments when the user taps on an image in the feed. 

2. Loading the comments can fail, so you must handle the UI states accordingly.
    - Show a loading spinner while loading the comments.
    - If it fails to load: show an error message.
    - If it loads successfully: show all loaded comments in the order they were returned by the remote API.

3. The loading should start automatically when the user navigates to the screen.
    - The user should also be able to reload the comments manually (pull-to-refresh)

4. At all times, the user should have a back button to return to the feed screen.
    - Cancel any running comments API requests when the user navigates back.

5. The comments screen layout should match the UI specs. 
    - Present the comment date using relative date formatting, e.g. "1 day ago"

6. The comments screen title should be localized in all languages supported in the project. 

7. The comments screen should support Light and Dark modes.

8. Write tests to validate your implementation, including unit, integration, and snapshot tests (aim to write the test first!).

9. Follow the specs and test-drive this feature from scratch.
