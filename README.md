[![tests](https://github.com/drud/ddev-cron/actions/workflows/tests.yml/badge.svg)](https://github.com/drud/ddev-cron/actions/workflows/tests.yml) ![project is maintained](https://img.shields.io/maintenance/yes/2022.svg)

# DDEV-CRON <!-- omit in toc -->

- [Intro](#intro)
- [Getting started](#getting-started)
- [Implementation](#implementation)

## Intro

This DDEV add-on helps to execute a command in the web container based on a cron schedule. Cron is a classic Linux/Unix service with a well-known configuration syntax.

The add-on

- Installs and runs the cron service inside the web container
- Adds a sample cron configuration that adds to a file every minute.
- Required DDEV v1.19.3 or higher.

*This extension is designed to be a generic implentation. See [Running TYPO3 Cron inside the web container](https://github.com/drud/ddev-contrib/tree/master/recipes/cronjob) for a specific example of a manual setup.*

## Getting started

- Install the add-on with `ddev get drud/ddev-cron`
- Update the provided `.ddev/config.cron.yaml` as you see fit with your expected cron jobs (and remove the demonstration line). You can also just add those demonstration lines to your `.ddev/config.yaml` and delete the `.ddev/config.cron.yaml`.
- `ddev restart`

## Implementation

The provided `web-build/Dockerfile.ddev-cron` and `web-build/cron.conf` configure the traditional cron daemon to run inside the web container.

The `config.cron.yaml` is a simple setup of a trivial cron job within the DDEV web container. It writes a crontab file to configure the cron daemon.

```yaml
hooks:
  post-start:
    # This adds an every-minute cronjob for your user; it runs "date" and appends that
    # to the "date.log" in your project root.
    # You can just `ls -l date.log` or `tail -f date.log` to see it happening.
    # The crontab can have more than one line for multiple jobs.
    # `ddev exec crontab -l` will show you the current crontab configuration
    - exec: printf "SHELL=/bin/bash\n* * * * * date >> /var/www/html/date.log\n" | crontab
```

The default file configures a job to write the date to a log file `date.log` every minute.
It is a simple arbitary example to show the service is working, and remind the user to change it to something more appropriate. You can add additional files into /etc/cron.d, or add additional lines to this one.

* If you need help figuring out the syntax of a cron job, see [crontab guru](https://crontab.guru/).
* For the usage of `crontab` see [crontab man page](https://manpages.debian.org/buster/cron/crontab.1.en.html).
* You can experiment with the `crontab` command inside the container by `ddev ssh` and then `crontab -e` for example, or use `ddev exec crontab -e`.
* If you want the cron to run on your local time instead of UTC, make sure to set `timezone` in your `.ddev/config.yaml`.
* Make sure that when you have tried manually executing the command you want to run inside the container and that it gets the expected results.
* If you are running a CMS command that requires access to the database, set the environment variable `IS_DDEV_PROJECT=true`

## Examples

**TYPO3 scheduler**: A cron to add on to the example and then run the TYPO3 scheduler every minute might be:

```yaml
  - exec: printf "SHELL=/bin/bash\n* * * * * date |& tee -a /var/www/html/date.log\n* * * * * IS_DDEV_PROJECT=true /var/www/html/vendor/bin/typo3 scheduler:run -vv |& tee -a /var/www/html/scheduler-log.txt\n" | crontab

```
See the results of this with `ddev exec crontab -l`:
```
SHELL=/bin/bash
* * * * * date |& tee -a /var/www/html/date.log
* * * * * cd /var/www/html && IS_DDEV_PROJECT=true vendor/bin/typo3 scheduler:run -vv |& tee -a /var/www/html/scheduler-log.txt
```

**Drupal cron**: A cron to run drupal's cron every 10 minutes via drush might be:

```yaml
  - exec: printf "SHELL=/bin/bash\n*/10 * * * * IS_DDEV_PROJECT=true DDEV_PHP_VERSION=8.0 /var/www/html/vendor/bin/drush cron -v |& tee -a /var/www/html/cron-log.txt\n" | crontab
```


**Contributed and maintained by [@tyler36](https://github.com/tyler36) based on the original [Running TYPO3 Cron inside the web container](https://github.com/drud/ddev-contrib/tree/master/recipes/cronjob) by [@thomaskieslich](https://github.com/thomaskieslich)**

**Originally Contributed by [@thomaskieslich](https://github.com/thomaskieslich) in <https://github.com/drud/ddev-contrib/tree/master/recipes/cronjob>)**
