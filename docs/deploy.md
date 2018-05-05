# Deployment guide

## Capistrano

Census can use Capistrano to deploy to staging and production servers. Adapt `staging.rb` and `production.rb` to your servers settings.

### Encryption

Use Capistrano `encryption` tasks to setup encryption for staging and production environments:

 * `cap [environment] encryption:setup`: Creates a configuration file and keys in the servers. If not executed, deployment won't work until it is ran. If it is ran again, it will fail and won't do anything.
 * `cap [environment] encryption:remove`: Deletes configuration file and keys created by `setup` task.
