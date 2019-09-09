# Census API notifications

Census uses [Hutch](https://github.com/gocardless/hutch) to notify client applications about changes on its data.

## Full status changed
:round_pushpin: A person status has changed.

- Message: `census.people.full_status_changed`
- Arguments:

Parameter                | Data type | Description                    | Format
-------------------------|-----------|--------------------------------|----------------
`person`                 |  string   | Person's qualified identifier  | `...@census`
`external_ids`           |  json     | Person's external systems ids
`state`                  |  string   | Person's state                 | `pending`, `enabled`, `cancelled` or `trashed`
`verification`           |  string   | Person's identity verification | `not_verified`, `verification_requested`, `verification_received`, `verified`, `mistake` or `fraud`
`membership_level`       |  string   | Person's membership level      | `follower` or `member`
`scope_code`             |  string   | Person's scope_code
`document_type`          |  string   | Person's document type         | `dni`, `nie` or `passport`
`age`                    |  integer  | Person's current age

* All parameters after `verification` are not included when the person is discarded.


## Confirm email change
:round_pushpin: An email change confirmation process should be started for this person with the given email.

- Message: `census.people.confirm_email_change`
- Arguments:

Parameter                | Data type | Description                    | Format
-------------------------|-----------|--------------------------------|----------------
`person`                 |  string   | Person's qualified identifier  | `...@census`
`external_ids`           |  json     | Person's external systems ids
`email`                  |  string   | Person's email
