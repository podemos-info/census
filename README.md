# Census

[![Build][build]][build_url]
[![Coverage][coverage]][coverage_url]
[![Maintainability][maintainability]][maintainability_url]

[build]: https://circleci.com/gh/podemos-info/census/tree/master.svg?style=svg
[build_url]: https://circleci.com/gh/podemos-info/census/tree/master

[coverage]: https://api.codeclimate.com/v1/badges/073f81918e3636dbc15a/test_coverage
[coverage_url]: https://codeclimate.com/github/podemos-info/census/test_coverage

[maintainability]: https://api.codeclimate.com/v1/badges/073f81918e3636dbc15a/maintainability
[maintainability_url]: https://codeclimate.com/github/podemos-info/census/maintainability

Census is an open source census management application. It is aimed to store people and payments data securely. It was created to be used within [Decidim](https://github.com/decidim/decidim), but it could be integrated with any other application. Currently, it can't be used as a standalone application, since it has no UI for end user operations.

**WARNING**: Census is still under heavy development, and it's not ready for use in production yet.

## Features
- Person data management. Its based on procedures. Operations over a person data (registrations, modifications, verifications, cancellations) are represented by procedures that could be accepted or rejected.
- Payments management. Each person can have payment methods and use them to create orders. Orders can be related to campaigns and payees and can be processed inline or in batches.
- Administration tool. A web application allow admins to perform adminitrative tasks. Different users roles are available for different type of users. Issues are created when admin action is required.
- Security. Sensible data is stored ciphered. Admin activity is tracked. Versions are stored for every data modification.
- API access. [Person procedures](docs/api-person.md) and [payments](docs/api-payments.md) can be created and queried using a JSON API.

## Development
Census is written in [Ruby on Rails](https://github.com/rails), and its admin interface is based on [Active Admin](https://github.com/activeadmin/activeadmin/).

### Setting up
* Install Ruby (>=2.4) and postgreSQL (>=9.4)
* Clone this repo
```
git clone https://github.com/podemos-info/census.git
```
* Install the project dependencies
```
cd census
bundle
```
* Create a database user with permissions and store its credentials in a new `.env` file, in the current directory. Check the [configurations guide](docs/configuration.md) to know all that can be configured in the application.
```
DATABASE_USERNAME=census
DATABASE_PASSWORD=census
```
* Create the database and seed it with test data
```
bundle exec rails db:setup
bundle exec rails db:seed
```
* Start the development server
```
bundle exec rails server
```
* Access to the [administration tool](http://localhost:3000). Different users are created for the different admin roles:
 * System user: `system0` (password `system`)
 * Data admin user: `data0` (password `data`)
 * Data user: `data_help0` (password `data_help`)
 * Payments user: `finances0` (password `finances`)

## Documentation
* [Configurations guide](docs/configuration.md)
* [People API](docs/api-person.md)
* [Payments API](docs/api-payments.md)
* [API notifications](docs/api-notifications.md)
* [Deployment guide](docs/deploy.md)
