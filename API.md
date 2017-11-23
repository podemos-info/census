# Census API

## Payments

### Order creation
:round_pushpin: Creates an order for a person. It can use an existing payment method or can create a new one.
```
POST api/v1/payments/orders
```

Parameter             | Data type | Description            | Only when `payment_method_type` is ...
----------------------|-----------|------------------------|------------------
`person_id`           |  integer  | Person identifier at Census
`description`         |  string   | Order description
`amount`              |  integer  | Order amount (in cents, `1000` will be 10.00€)
`campaign_code`       |  string   | Unique identifier for the campaign related to the order
`payment_method_type` |  string   | `existing_payment_method`, `direct_debit` or `credit_card_external`
`payment_method_id`   |  integer  | Payment method identifier at Census | `existing_payment_method`
`return_url`          |  string   | After payment back URL (string must include `__RESULT__` that will be replaced by `ok` or `ko`)  | `credit_card_external`
`iban`                |  string   | Normalized bank account's IBAN (no speces or symbols, only letters and numbers) | `direct_debit`

#### Return value
* When order is successfully created, server response will be `:created` (HTTP 201) with a JSON with the used payment method identifier in the `payment_method_id` key.
* When using `credit_card_external` payment method, server response will be `:accepted` (HTTP 202) and the JSON will also include the `form` key, with information to generate a page with a `<FORM>` tag that should be sumbitted to the payment gateway. This form could be submitted automatically with JavaSscript or could present a summary of the payment and a submit button to proceed. This hash will contain two keys:
  * `action` is the URL where the form should be submitted
  * `fields` is a `Hash` with key/value pairs that should be included in the form with hidden input fields.
* When there is an error creating the order, server response will be `:unprocessable_entity` (HTTP 422) and a JSON with the errors.

### Payment methods retrieval
:round_pushpin: Retrieves all the payment methods for a person.
```
GET api/v1/payments/payment_methods
```

Parameter             | Data type | Description
----------------------|-----------|------------------------
`person_id`           |  integer  | Person identifier at Census

#### Return value
* When the person exists in the database, server response will be `:ok` (HTTP 200) with a JSON with all the payment methods related to that person:
 (fields `id`.

Parameter             | Data type | Description
----------------------|-----------|------------------------
`id`                  |  integer  | Payment method identifier at Census
`name`                |  string   | Payment method human name
`type`                |  string   | Payment method type: `PaymentMethods::DirectDebit` or `PaymentMethods::CreditCard`

* When there is no person for the given `person_id`, server response will be `:unprocessable_entity` (HTTP 422) and an empty JSON.
