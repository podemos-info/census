# Census API: People

## Person registration
:round_pushpin: Creates a registration procedure for a person.
```
POST api/v1/people
```

Parameter             | Data type | Description                   | Format
----------------------|-----------|-------------------------------|---------------------
`first_name`          |  string   | Person's first name
`last_name1`          |  string   | Person's first last name
`last_name2`          |  string   | Person's second last name
`document_type`       |  string   | Person's document type        | `dni`, `nie` or `passport`
`document_id`         |  string   | Person's document id
`document_scope_code` |  string   | Person's document scope code
`born_at`             |  date     | Person's born date            | `YYYY-MM-DD`
`gender`              |  string   | Person's gender               | `male`, `female`, `other` or `undisclosed`
`address`             |  string   | Person's address
`address_scope_code`  |  string   | Person's address_scope_code
`postal_code`         |  string   | Person's postal_code
`email`               |  string   | Person's email
`scope_code`          |  string   | Person's scope_code
`phone`               |  string   | Person's phone

* All parameters are mandatory.

### Return value
* When the person registration is successfully created, server response will be `:accepted` (HTTP 202) and the JSON will include the `person_id` key with the new person identifier.
* When the given parameters for the person are invalid, server response will be `:unprocessable_entity` (HTTP 422) and a JSON with the errors for each parameter.
* When there is an error creating the registration, server response will be `:server_internal_error` (HTTP 500).

## Person data changes
:round_pushpin: Creates a person data change procedure.
```
PATCH api/v1/people
```

Parameter             | Data type | Description                   | Format
----------------------|-----------|-------------------------------|---------------------
`person_id`           |  integer  | Person's identifier
`first_name`          |  string   | Person's first name
`last_name1`          |  string   | Person's first last name
`last_name2`          |  string   | Person's second last name
`document_type`       |  string   | Person's document type        | `dni`, `nie` or `passport`
`document_id`         |  string   | Person's document id
`document_scope_code` |  string   | Person's document scope code
`born_at`             |  date     | Person's born date            | `YYYY-MM-DD`
`gender`              |  string   | Person's gender               | `male`, `female`, `other` or `undisclosed`
`address`             |  string   | Person's address
`address_scope_code`  |  string   | Person's address_scope_code
`postal_code`         |  string   | Person's postal_code
`email`               |  string   | Person's email
`scope_code`          |  string   | Person's scope_code
`phone`               |  string   | Person's phone

* All parameters are optional, except `person_id`.

### Return value
* When the person data change request is successfully created, server response will be `:accepted` (HTTP 202).
* When the given parameters for the person are invalid, server response will be `:unprocessable_entity` (HTTP 422) and a JSON with the errors for each parameter.
* When there is an error creating the person data change, server response will be `:server_internal_error` (HTTP 500).

## Person cancellation
:round_pushpin: Creates a cancellation procedure for a person.
```
POST api/v1/people
```

Parameter             | Data type | Description
----------------------|-----------|-------------------------------
`person_id`           |  integer  | Person's identifier
`reason`              |  string   | Reason for the cancellation (optional)

### Return value
* When the person cancellation is successfully created, server response will be `:accepted` (HTTP 202).
* When the given parameters for the procedure are invalid, server response will be `:unprocessable_entity` (HTTP 422) and a JSON with the errors for each parameter.
* When there is an error creating the cancellation, server response will be `:server_internal_error` (HTTP 500).

## Membership level change
:round_pushpin: Creates a membership level change procedure for a person.
```
POST api/v1/people/:person_id/membership_levels
```

Parameter             | Data type | Description                   | Format
----------------------|-----------|-------------------------------|---------------------
`person_id`           |  integer  | Person's identifier (in URL)
`membership_level`    |  string   | Target level                  | `follower` or `member`

* All parameters are mandatory.

### Return value
* When the membership level change request is successfully created, server response will be `:accepted` (HTTP 202).
* When the given parameters for the procedure are invalid, server response will be `:unprocessable_entity` (HTTP 422) and a JSON with the errors for each parameter.
* When there is an error creating the membership level change, server response will be `:server_internal_error` (HTTP 500).

## Document verification
:round_pushpin: Creates a document verification procedure for a person.
```
POST api/v1/people/:person_id/document_verifications
```

Parameter             | Data type | Description
----------------------|-----------|-------------------------------
`person_id`           |  integer  | Person's identifier
`reason`              |  string   | Reason for the cancellation (optional)

### Return value
* When the document verification is successfully created, server response will be `:accepted` (HTTP 202).
* When the given parameters for the procedure are invalid, server response will be `:unprocessable_entity` (HTTP 422) and a JSON with the errors for each parameter.
* When there is an error creating the cancellation, server response will be `:server_internal_error` (HTTP 500).
