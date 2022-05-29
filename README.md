[![tests](https://github.com/tyler36/ddev-cron/actions/workflows/tests.yml/badge.svg)](https://github.com/tyler36/ddev-cron/actions/workflows/tests.yml) ![project is maintained](https://img.shields.io/maintenance/yes/2022.svg)

# DDEV-CRON <!-- omit in toc -->
- [Intro](#intro)
- [Getting started](#getting-started)
- [Implementation](#implementation)

## Intro

This DDEV add-on helps to execute a command in the web container based on a cron schedule. Cron is a classic Linux/Unix service with a well-known configuration syntax.

The add-on 
* Installs and runs the cron service inside the web container
* Adds a sample cron configuration that adds to a file every minute.

> **Warning**
> If you already have a `.ddev/web-build/Dockerfile` in your project, you'll want to adapt it with
> the one provided here, and `ddev get` will override the one you have.


This extension is designed to be a generic implentation. See [Running TYPO3 Cron inside the web container](https://github.com/drud/ddev-contrib/tree/master/recipes/cronjob) for a specific example of a manual setup.

## Getting started

- Install the add-on

```shell
ddev get tyler36/cron
```

- Update the provided `./.ddev/config.cron.yaml` as you see fit with your expected cron jobs (and remove the demonstration line). You can also just add the demonstration lines to your `.ddev/config.yaml`.
- `ddev restart`


## Implementation

The provided `web-build/Dockerfile` and `web-build/cron.conf` configure the traditional cron daemon to run inside the web container.

The `config.cron.yaml` is a simple implentation of cron within the DDEV web container. It writes a crontab file to configure the cron daemon.

```yaml
hooks:
  post-start:
      # This line creates a cron job, ddev-cron-time, and configures it to run every minute
    - exec: echo '*/1 * * * * root date | tee -a /var/www/html/time.log' | sudo tee -a /etc/cron.d/ddev-cron-time
```

The default file configures a job (`ddev-cron-time`) to write the date to a log file `time.log` every minute.
It is a simple arbitary example to show the service is working, and remind the user to change it to something more appropriate. You can add additional files into /etc/cron.d, or add additional lines to this one.

**Contributed and maintained by [@tyler36](https://github.com/tyler36) based on the original [Running TYPO3 Cron inside the web container](https://github.com/drud/ddev-contrib/tree/master/recipes/cronjob) by [@thomaskieslich](https://github.com/thomaskieslich)**

**Originally Contributed by [@thomaskieslich](https://github.com/thomaskieslich) in <https://github.com/drud/ddev-contrib/tree/master/recipes/cronjob>)**
