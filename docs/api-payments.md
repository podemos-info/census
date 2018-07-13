# Census API: Payments

## Order creation
:round_pushpin: Creates an order for a person. It can use an existing payment method or can create a new one.
```
POST api/v1/payments/orders
```

Parameter             | Data type | Description            | Only when `payment_method_type` is ...
----------------------|-----------|------------------------|------------------
`person_id`           |  string   | Person's qualified identifier
`description`         |  string   | Order description
`amount`              |  integer  | Order amount (in cents, `1000` will be 10.00€)
`campaign_code`       |  string   | Unique identifier for the campaign related to the order
`payment_method_type` |  string   | `existing_payment_method`, `direct_debit` or `credit_card_external`
`payment_method_id`   |  integer  | Payment method identifier at Census | `existing_payment_method`
`return_url`          |  string   | After payment back URL (string must include `__RESULT__` that will be replaced by `ok` or `ko`)  | `credit_card_external`
`iban`                |  string   | Normalized bank account's IBAN (no speces or symbols, only letters and numbers) | `direct_debit`

### Return value
* When the order is successfully created, server response will be `:created` (HTTP 201) with a JSON with the used payment method identifier in the `payment_method_id` key.
* When using `credit_card_external` payment method, server response will be `:accepted` (HTTP 202) and the JSON will also include the `form` key, with information to generate a page with a `<FORM>` tag that should be sumbitted to the payment gateway. This form could be submitted automatically with JavaSscript or could present a summary of the payment and a submit button to proceed. This hash will contain two keys:
  * `action` is the URL where the form should be submitted
  * `fields` is a `Hash` with key/value pairs that should be included in the form with hidden input fields.
* When the given parameters for the order, server response will be `:unprocessable_entity` (HTTP 422) and a JSON with the errors for each parameter.
* When there is an error creating the order, server response will be `:server_internal_error` (HTTP 500).

## Totals
:round_pushpin: Returns total amount for processed orders for a campaign and/or a person. Also they can be filtered by a span of time.
```
GET api/v1/payments/orders/total
```

Parameter             | Data type | Description
----------------------|-----------|------------------------
`campaign_code`       |  string   | Optional. Unique identifier for the campaign
`person_id`           |  string   | Optional. Person's qualified identifier
`from_date`           |  datetime | Optional. Include orders created after this date (use ISO datetime format)
`until_date`          |  datetime | Optional. Include orders created before this date (use ISO datetime format)

### Return value
* Server response will be `:ok` (HTTP 200) with a JSON with the `amount` key.
* Person or campaign filter should be used, server response will be `:unprocessable_entity` (HTTP 422) otherwise.

## Payment methods retrieval
:round_pushpin: Retrieves all the payment methods for a person.
```
GET api/v1/payments/payment_methods
```

Parameter             | Data type | Description
----------------------|-----------|------------------------
`person_id`           |  string   | Person's qualified identifier

### Return value
* When the person exists in the database, server response will be `:ok` (HTTP 200) with a JSON with all the payment methods related to that person:
 (fields `id`.

Parameter             | Data type | Description
----------------------|-----------|------------------------
`id`                  |  integer  | Payment method identifier at Census
`name`                |  string   | Payment method human name
`type`                |  string   | Payment method type: `PaymentMethods::DirectDebit` or `PaymentMethods::CreditCard`

* When there is no person for the given `person_id`, server response will be `:unprocessable_entity` (HTTP 422) and an empty JSON.

## Payment method retrieval
:round_pushpin: Retrieve a payment method information.
```
GET api/v1/payments/payment_methods/:id
```

Parameter             | Data type | Description
----------------------|-----------|------------------------
`id`                  |  integer  | Payment method identifier at Census

### Return value
* When the payment method exists in the database, server response will be `:ok` (HTTP 200) with a JSON with the payment method information:
 (fields `id`.

Parameter             | Data type | Description
----------------------|-----------|------------------------
`id`                  |  integer  | Payment method identifier at Census
`name`                |  string   | Payment method human name
`type`                |  string   | Payment method type: `PaymentMethods::DirectDebit` or `PaymentMethods::CreditCard`

* When there is no payment method for the given `id`, server response will be `:not_found` (HTTP 404) and an empty JSON.
