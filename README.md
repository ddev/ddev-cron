[![tests](https://github.com/ddev/ddev-cron/actions/workflows/tests.yml/badge.svg)](https://github.com/ddev/ddev-cron/actions/workflows/tests.yml) ![project is maintained](https://img.shields.io/maintenance/yes/2024.svg)

# DDEV-CRON <!-- omit in toc -->

- [Introduction](#introduction)
- [Getting started](#getting-started)
- [Implementation](#implementation)
- [Examples](#examples)
  - [TYPO3 scheduler](#typo3-scheduler)
  - [Drupal cron](#drupal-cron)
  - [Laravel cron](#laravel-cron)

## Introduction

This DDEV add-on helps to execute a command in the web container based on a cron schedule. Cron is a classic Linux/Unix service with a well-known configuration syntax.

The add-on:

- Installs and runs the cron service inside the web container
- Adds an example job that writes out the current time.
- Required DDEV v1.19.3 or higher.

*This extension is designed to be a generic implementation. See [Running TYPO3 Cron inside the web container](https://github.com/ddev/ddev-contrib/tree/master/recipes/cronjob) for a specific example of a manual setup.*

## Getting started

- Install the DDEV cron add-on:

  ```shell
  ddev get ddev/ddev-cron
  ```

- Update `./.ddev/web-build/custom.cron` with your required commands.
  - Remove `#ddev-generated` to prevent DDEV from overriding the file.
- Custom the cron service, if required, by updating `./.ddev/web-build/cron.conf`
  - Remove `#ddev-generated` to prevent DDEV from overriding the file.
- Restart DDEV to apply any changes:

  ```shell
  ddev restart
  ```

## Implementation

Out of the box, this add-on writes the date to a log file `time.log` every minute.
This serves as an example implementation, provides proof the service is working, and is the basis for tests.

- If you need help figuring out the syntax of a cron job, see [crontab guru](https://crontab.guru/).
- For the usage of `crontab` see [crontab man page](https://manpages.debian.org/buster/cron/crontab.1.en.html).
- Experiment with the `crontab` command inside the container by `ddev ssh` and then `crontab -e` for example, or use `ddev exec crontab -e`.
- If you want the cron to run on your local time instead of UTC, make sure to set `timezone` in your `.ddev/config.yaml`.
- Make sure that when you have tried manually executing the command you want to run inside the container and that it gets the expected results.
- If you are running a CMS command that requires access to the database, set the environment variable `IS_DDEV_PROJECT=true`

## Examples

### TYPO3 scheduler

A cron to add on to the example and then run the TYPO3 scheduler every minute might be:

```cron
  * * * * * cd /var/www/html && IS_DDEV_PROJECT=true vendor/bin/typo3 scheduler:run -vv |& tee -a /var/www/html/scheduler-log.txt
```

### Drupal cron

A cron to run drupal's cron every 10 minutes via drush might be:

```cron
*/10 * * * * IS_DDEV_PROJECT=true DDEV_PHP_VERSION=8.0 /var/www/html/vendor/bin/drush cron -v |& tee -a /var/www/html/cron-log.txt
```

### Laravel cron

A cron to run the Laravel scheduler every minute would be:

```cron
* * * * * cd /var/www/html && IS_DDEV_PROJECT=true php artisan schedule:run >> /dev/null 2>&1
```

**Contributed and maintained by [@tyler36](https://github.com/tyler36) based on the original [Running TYPO3 Cron inside the web container](https://github.com/ddev/ddev-contrib/tree/master/recipes/cronjob) by [@thomaskieslich](https://github.com/thomaskieslich)**

**Originally Contributed by [@thomaskieslich](https://github.com/thomaskieslich) in <https://github.com/ddev/ddev-contrib/tree/master/recipes/cronjob>)**
