[![tests](https://github.com/drud/ddev-ddev-cron/actions/workflows/tests.yml/badge.svg)](https://github.com/drud/ddev-ddev-cron/actions/workflows/tests.yml) ![project is maintained](https://img.shields.io/maintenance/yes/2022.svg)

# DDEV-CRON <!-- omit in toc -->

- [Intro](#intro)
- [Getting started](#getting-started)
- [Implementation](#implementation)

## Intro

This extension helps to execute a command based on a schedule.

It does this by a creating a new crontab job at startup and executing it at the specified time.

This extension is designed to be a generic implentation. See [Running TYPO3 Cron inside the web container](https://github.com/drud/ddev-contrib/tree/master/recipes/cronjob) for a specific example of a manual setup.

## Getting started

- Install the service

```shell
ddev get tyler36/cron
```

- Update `./.ddev/config.cron.yml` with your requirments.
- Restart DDEV

```shell
ddev restart
```

## Implementation

The `config.cron.yml` is a simple implentation of cron within the DDEV web container.

It has 3 main parts:

- Install the cron package
- Write a crontab file
- Update the permissions and start the cron service.

```yml
# Install required packages
webimage_extra_packages: [cron]

hooks:
  post-start:
      # This line creates a job, ddev-cron-time, and configures it to run every minute
    - exec: echo '*/1 * * * * root date | tee -a /var/www/html/time.log' | sudo tee -a /etc/cron.d/ddev-cron-time
      # This line sets permissions ands starts the cron service
    - exec: sudo chmod 0600 /etc/cron.d/ddev-cron-time && sudo service cron start
```

The default file configures a job (`ddev-cron-time`) to write the date to a log file `time.log` every minute.
It is a simple arbitary example to show the service is working, and remind the user to change it to something more appropriate.

**Contributed and maintained by [@tyler36](https://github.com/tyler36) based on the original [Running TYPO3 Cron inside the web container](https://github.com/drud/ddev-contrib/tree/master/recipes/cronjob) by [@thomaskieslich](https://github.com/thomaskieslich)**

**Originally Contributed by [@thomaskieslich](https://github.com/thomaskieslich) in <https://github.com/drud/ddev-contrib/tree/master/recipes/cronjob>)
