# Configuration

These are all the values than can/should be defined in your .env file to customize your application.

## Database

We use a database to store most of the application data. Currently, only PostgreSQL is supported, since we use JSONB columns and its full text search features.

Key                           | Example for value            | Description
------------------------------|------------------------------|------------------------
DATABASE_HOST                 | localhost                    | Database host.
DATABASE_USERNAME             | census                       | Database user.
DATABASE_PASSWORD             | census                       | Database password.
DATABASE_PORT                 | 5432                         | Database port.
DATABASE_URL                  | postgres://census:census@localhost:5432/census | Database connection URL. Replaces previous settings on staging and production environments.

## Emails and SMS sending

We use SMTP to send emails to people and [Esendex](https://www.esendex.es/) to send them SMSs.

Key                           | Example for value            | Description
------------------------------|------------------------------|------------------------
ESENDEX_ACCOUNT               | census                       | Esendex account.
ESENDEX_USERNAME              | info@example.org             | Esendex username.
ESENDEX_PASSWORD              | potato                       | Esendex password.
MAILS_FROM                    | noreply@example.org          | Email address used to send emails.
SMTP_ADDRESS                  | smtp.example.org             | SMTP server address.
SMTP_AUTHENTICATION           | plain                        | SMTP authentication mode.
SMTP_ENABLE_STARTTLS_AUTO     | true                         | Detects if STARTTLS is enabled in your SMTP server and starts to use it.
SMTP_USER_NAME                | census                       | If your mail server requires authentication, set the username in this setting.
SMTP_OPENSSL_VERIFY_MODE      | none                         | 'none' or 'peer'. When using TLS, you can set how OpenSSL checks the certificate.
SMTP_PASSWORD                 | census                       | If your mail server requires authentication, set the password in this setting.
SMTP_PORT                     | 25                           | SMTP server port.

## Domains and IPs

The applications needs some URLs and IPs to work properly.

ALLOWED_IPS_API_CLIENTS       | 10.0.0.15 10.0.0.16          | Allow these IPs to access API.
CAS_SERVER                    | https://cas.example.org      | CAS server URL. Optional.
HOST_URL                      | https://census.example.org   | URL where the application will be running.

## Queues

We use RabbitMQ for message queue processing. We use [Hutch](https://github.com/gocardless/hutch) to allow external applications to be notified about person changes and [Sneakers](http://jondot.github.io/sneakers/) to implement background jobs.

Key                           | Example for value            | Description
------------------------------|------------------------------|------------------------
HUTCH_MQ_HOST                 | localhost                    | RabbitMQ host for hutch.
HUTCH_MQ_USERNAME             | hutch                        | RabbitMQ user for hutch.
HUTCH_MQ_PASSWORD             | hutch                        | RabbitMQ password for hutch.
HUTCH_MQ_PORT                 | 5672                         | RabbitMQ port for hutch.
HUTCH_MQ_VHOST                | /hutch                       | RabbitMQ vhost for hutch.
HUTCH_ENABLE_HTTP_API_USE     | false                        | Use or not RabbitMQ HTTP API.
SNEAKERS_HOST                 | localhost                    | RabbitMQ host for sneakers.
SNEAKERS_USERNAME             | jobs                         | RabbitMQ user for sneakers.
SNEAKERS_PASSWORD             | jobs                         | RabbitMQ password for sneakers.
SNEAKERS_VHOST                | /jobs                        | RabbitMQ vhost for sneakers.
SNEAKERS_PORT                 | 5672                         | RabbitMQ port for sneakers.

## Payments

We allow credit card and direct debit payments. The first one is done with [ActiveMerchant](http://activemerchant.org/) and it currently supports [Redsys](http://www.redsys.es/). The second one is done throught SEPA formats and it's implemented with the [SEPA King](https://github.com/salesking/sepa_king) gem.

Key                           | Example for value            | Description
------------------------------|------------------------------|------------------------
ALLOWED_IPS_CALLBACK_PAYMENTS | 99.9.9.99 99.9.9.100         | Allow these IPs to access to payments callback endpoint.
REDSYS_NAME                   | CENSUS                       | Redsys username.
REDSYS_MERCHANT_ID            | 123456789                    | Redsys merchant ID.
REDSYS_SECRET_KEY             | abcdefghijklmno              | Redsys secret key.
REDSYS_TERMINAL               | 001                          | Redsys terminal.
SEPA_NAME                     | CENSUS                       | Organization SEPA name.
SEPA_IBAN                     | DE89370400440532013000       | Organization SEPA IBAN.
SEPA_BIC                      | DEUTDEFFXXX                  | Organization SEPA BIC code.
SEPA_CREDITOR_IDENTIFIER      | DE12345678A12345678          | Organization SEPA creditor identifier.

## Error reporting

We use [Errbit](https://github.com/errbit/errbit) to receive [Airbrake](https://airbrake.io/) messages.

Key                           | Example for value                | Description
------------------------------|----------------------------------|------------------------
AIRBRAKE_API_KEY              | 1234567890abcedf1234567890abcdef | Airbrake API key.
AIRBRAKE_HOST                 | https://errbit.example.org       | Airbrake host URL.
AIRBRAKE_PROJECT_ID           | 1                                | Airbrake project ID.

## Deployment

We use [Capistrano](https://capistranorb.com/) to deploy this application to our servers.

Key                           | Example for value            | Description
------------------------------|------------------------------|------------------------
SEED_PASSWORDS_PREFIX         | staging_                     | Prefix used for seeded users password (only for testing)
STAGING_SERVER_MASTER_HOST    | census-staging-master        | Staging server master host
STAGING_SERVER_MASTER_PORT    | 22                           | Staging server master SSH port
STAGING_SERVER_SLAVE_HOST     | census-staging-slave         | Staging server slave host
STAGING_SERVER_SLAVE_PORT     | 22                           | Staging server slave SSH port
STAGING_USER                  | capistrano                   | Staging server user (master and slave)
PRODUCTION_SERVER_MASTER_HOST | census-production-master     | Production server master host
PRODUCTION_SERVER_MASTER_PORT | 22                           | Production server master SSH port
PRODUCTION_SERVER_SLAVE_HOST  | census-production-slave      | Production server slave host
PRODUCTION_SERVER_SLAVE_PORT  | 22                           | Production server slave SSH port
PRODUCTION_USER               | capistrano                   | Production server user (master and slave)

You can also create files to override settings.yml values locally, as explained [here](https://github.com/railsconfig/config#developer-specific-config-files).

## Development

This variables are only useful on the development environment.

Key                           | Example for value            | Description
------------------------------|------------------------------|------------------------
ALLOWED_IPS_DEVELOPMENT       | 10.0.0.14                    | Allow these IPs to debug application (development env only).
API_TESTS                     | 1                            | If present, allows external applications to run tests against a census development server. For example, it allows to bypass OTP validations.
