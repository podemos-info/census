# Census API: People

## Qualified identifiers
:information_source: A person qualified identifier is built joining its numeric identifier and the system name with an at sign (@). For example, a person could be identified with the qualified identifier `123@census`, and also with `126@decidim`. Also, an identifier by document ID could be used, in the form `1R@document_id`. Census API always identify people using its qualified identifier to avoid mixing-up when working with numeric identifiers only.

## Person registration
:round_pushpin: Creates a registration procedure for a person.
```
POST api/v1/people
```

Parameter             | Data type | Description                   | Format
----------------------|-----------|-------------------------------|---------------------
`person_id`           |  string   | Person's qualified identifier
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

* All parameters are mandatory, except `person_id`.

### Return value
* When the person registration is successfully created, server response will be `:accepted` (HTTP 202) and the JSON will include the `person_id` key with the new person identifier.
* When the given parameters for the person are invalid, server response will be `:unprocessable_entity` (HTTP 422) and a JSON with the errors for each parameter.
* When there is an error creating the registration, server response will be `:server_internal_error` (HTTP 500).

## Person data changes
:round_pushpin: Creates a person data change procedure.
```
PATCH api/v1/people/:person_id
```

Parameter             | Data type | Description                   | Format
----------------------|-----------|-------------------------------|---------------------
`person_id`           |  string   | Person's qualified identifier
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
DELETE api/v1/people/:person_id
```

Parameter             | Data type | Description
----------------------|-----------|-------------------------------
`person_id`           |  string   | Person's qualified identifier
`channel`             |  string   | Application name used to perform the cancellation request
`reason`              |  string   | Reason for the cancellation (optional)

### Return value
* When the person cancellation is successfully created, server response will be `:accepted` (HTTP 202).
* When the given parameters for the procedure are invalid, server response will be `:unprocessable_entity` (HTTP 422) and a JSON with the errors for each parameter.
* When there is an error creating the cancellation, server response will be `:server_internal_error` (HTTP 500).

## Person retrieval
:round_pushpin: Retrieve the person data. It also allows to retrieve the person's data as it was at a given timestamp.
```
GET api/v1/people/:person_id
```

Parameter             | Data type | Description                                    | Format
----------------------|-----------|------------------------------------------------|----------------
`person_id`           |  string   | Person's qualified identifier
`with_scope`          |  boolean  | Include scopes information in the response (optional) | `true` or `false` (by default)
`version_at`          |  datetime | Timestamp used to query person data (optional) | `YYYY-MM-DD HH:MM +HH:MM`

### Return value
* When the person exists in the database, server response will be `:ok` (HTTP 200) with a JSON with all the person data:
 (fields `id`.

Parameter                | Data type | Description                    | Format
-------------------------|-----------|--------------------------------|----------------
`person_id`              |  string   | Person's qualified identifier
`first_name`             |  string   | Person's first name
`last_name1`             |  string   | Person's first last name
`last_name2`             |  string   | Person's second last name
`document_type`          |  string   | Person's document type         | `dni`, `nie` or `passport`
`document_id`            |  string   | Person's document id
`document_scope_code`    |  string   | Person's document scope code
`born_at`                |  date     | Person's born date             | `YYYY-MM-DD`
`gender`                 |  string   | Person's gender                | `male`, `female`, `other` or `undisclosed`
`address`                |  string   | Person's address
`address_scope_code`     |  string   | Person's address_scope_code
`postal_code`            |  string   | Person's postal_code
`email`                  |  string   | Person's email
`scope_code`             |  string   | Person's scope_code
`phone`                  |  string   | Person's phone
`state`                  |  string   | Person's state                 | `pending`, `enabled`, `cancelled` or `trashed`
`membership_level`       |  string   | Person's membership level      | `follower` or `member`
`verification`           |  string   | Person's identity verification | `not_verified`, `verification_requested`, `verification_received`, `verified`, `mistake` or `fraud`
`phone_verification`     |  string   | Person's phone verification    | `not_verified`, `verified` or `reassigned`
`external_ids`           |  json     | Person's external systems ids
`additional_information` |  json     | Person's misc additional information
`membership_allowed?`    |  boolean  | Is person is allowed to be member | `true` or `false`
`scopes`                 |  json     | Person's scopes information (if requested) | Array of scope objects (`id`, `name`, `scope_type`, `code` and `mappings`)

* When there is no person for the given `person_id`, server response will be `:not_found` (HTTP 404) and an empty JSON.

## Person set additional information
:round_pushpin: Sets additional information for the person.
```
POST api/v1/people/:person_id/additional_informations
```

Parameter             | Data type | Description                         | Format
----------------------|-----------|-------------------------------------------------
`person_id`           |  string   | Person's qualified identifier
`key`                 |  string   | Additional information key
`json_value`          |  string   | Additional information value        | Serialized JSON

### Return value
* When the information is successfully saved, server response will be `:accepted` (HTTP 202).
* When the given parameters for the procedure are invalid, server response will be `:unprocessable_entity` (HTTP 422) and a JSON with the errors for each parameter.
* When there is an error saving the information, server response will be `:server_internal_error` (HTTP 500).


## Membership level change
:round_pushpin: Creates a membership level change procedure for a person.
```
POST api/v1/people/:person_id/membership_levels
```

Parameter             | Data type | Description                   | Format
----------------------|-----------|-------------------------------|---------------------
`person_id`           |  string   | Person's qualified identifier
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
`person_id`           |  string   | Person's qualified identifier
`files`               |  json     | A JSON with an array of hashes with three fields: `filename`, `content_type` and `base_64_content`.

### Return value
* When the document verification is successfully created, server response will be `:accepted` (HTTP 202).
* When the given parameters for the procedure are invalid, server response will be `:unprocessable_entity` (HTTP 422) and a JSON with the errors for each parameter.
* When there is an error creating the verification, server response will be `:server_internal_error` (HTTP 500).

## Start a phone verification
:round_pushpin: Starts a phone verification sending an SMS with the code to the person or given phone.
```
GET api/v1/people/:person_id/phone_verifications/new
```

Parameter             | Data type | Description
----------------------|-----------|-------------------------------
`person_id`           |  string   | Person's qualified identifier
`phone`               |  string   | A different phone number to be verified (optional)

### Return value
* When the message is successfully sent, server response will be `:accepted` (HTTP 202).
* When the given parameters for the procedure are invalid, server response will be `:unprocessable_entity` (HTTP 422) and a JSON with the errors for each parameter.
* When there is an error sending the message, server response will be `:server_internal_error` (HTTP 500).


## Phone verification
:round_pushpin: Creates a phone verification procedure for a person.
```
POST api/v1/people/:person_id/phone_verifications
```

Parameter             | Data type | Description
----------------------|-----------|-------------------------------
`person_id`           |  string   | Person's qualified identifier
`received_code`       |  string   | The validation code received in the phone
`phone`               |  string   | A different phone number to be verified (optional)

### Return value
* When the phone verification is successfully created, server response will be `:accepted` (HTTP 202).
* When the given parameters for the procedure are invalid, server response will be `:unprocessable_entity` (HTTP 422) and a JSON with the errors for each parameter.
* When there is an error creating the phone verification, server response will be `:server_internal_error` (HTTP 500).

## Procedures
:round_pushpin: Retrieve all the pending procedures for the person.
```
GET api/v1/people/:person_id/procedures
```

Parameter             | Data type | Description
----------------------|-----------|-------------------------------
`person_id`           |  string   | Person's qualified identifier

### Return value
* When the person exists in the database, server response will be `:ok` (HTTP 200) and a JSON with all the pending procedures related to the person:
 (fields `id`.

Parameter             | Data type | Description
----------------------|-----------|------------------------
`id`                  |  integer  | Procedure identifier at Census
`type`                |  string   | Procedure type: `Procedures::Registration`, `Procedures::PersonDataChange`, `Procedures::MembershipLevelChange`, `Procedures::DocumentVerification` or `Procedures::Cancellation`
`information`         |  string   | Payment method human name

* When there is no person for the given `person_id`, server response will be `:unprocessable_entity` (HTTP 422) and an empty JSON.
