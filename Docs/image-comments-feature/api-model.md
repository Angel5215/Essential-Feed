
# Model Specs

## Feed Image Comment

| Property      | Type                    |
|:-------------:|:-----------------------:|
| `id`          | `UUID`                  |
| `message`     | `String`                |
| `created_at`  | `Date (ISO8601 String)` |
| `author`      | `CommentAuthorObject`   |

## Feed Image Comment Author

| Property   | Type     |
|:----------:|:--------:|
| `username` | `String` |

## Payload Contract

```json
// GET /image/{image-id}/comments

// 200 RESPONSE

{
	"items": [
		{
			"id": "a UUID",
			"message": "a message",
			"created_at": "2020-05-20T11:24:59+0000",
			"author": {
				"username": "a username"
			}
		},
		{
			"id": "another UUID",
			"message": "another message",
			"create at": "2020-05-19T14:23:53+0000",
			"author": {
				"username": "another username"
			}
		},
		...
	]
}
```

## URLs

- **Base URL**: 
    - http://image-comments-challenge.essentialdeveloper.com

- **Feed URL**: `[Base URL]` + `/feed`
    - http://image-comments-challenge.essentialdeveloper.com/feed

- **Image Comments URL**: `[Base URL]` + `/image/{image-id}/comments`
    - http://image-comments-challenge.essentialdeveloper.com/image/{image-id}/comments

