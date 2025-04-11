#!/usr/bin/env bats

# Bats is a testing framework for Bash
# Documentation https://bats-core.readthedocs.io/en/stable/
# Bats libraries documentation https://github.com/ztombol/bats-docs

# For local tests, install bats-core, bats-assert, bats-file, bats-support
# And run this in the add-on root directory:
#   bats ./tests/test.bats
# To exclude release tests:
#   bats ./tests/test.bats --filter-tags '!release'
# For debugging:
#   bats ./tests/test.bats --show-output-of-passing-tests --verbose-run --print-output-on-failure

setup() {
  set -eu -o pipefail

  # Override this variable for your add-on:
  export GITHUB_REPO=ddev/ddev-cron

  TEST_BREW_PREFIX="$(brew --prefix 2>/dev/null || true)"
  export BATS_LIB_PATH="${BATS_LIB_PATH}:${TEST_BREW_PREFIX}/lib:/usr/lib/bats"
  bats_load_library bats-assert
  bats_load_library bats-file
  bats_load_library bats-support

  export DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")/.." >/dev/null 2>&1 && pwd)"
  export PROJNAME="test-$(basename "${GITHUB_REPO}")"
  mkdir -p ~/tmp
  export TESTDIR=$(mktemp -d ~/tmp/${PROJNAME}.XXXXXX)
  export DDEV_NONINTERACTIVE=true
  export DDEV_NO_INSTRUMENTATION=true
  ddev delete -Oy "${PROJNAME}" >/dev/null 2>&1 || true
  cd "${TESTDIR}"
  run ddev config --project-name="${PROJNAME}" --project-tld=ddev.site
  assert_success
  run ddev start -y
  assert_success
  echo "# ddev started at $(date)" >&3
}

health_checks() {
  # Make sure cron process is running.
  # We use `time_cron_checks` to check the example cron job is actually correctly implemented.
  # This is due to the need to test the health-check when there are no jobs added.
  run ddev exec 'sudo killall -0 cron'
  assert_success
}

time_cron_checks() {
  # ASSERT time.log was written to
  grep UTC time.log

  # ASSERT job displays under current user's crontab
  ddev exec crontab -l | grep '* * * * * date | tee -a /var/www/html/time.log'
}

teardown() {
  set -eu -o pipefail
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1
  [ "${TESTDIR}" != "" ] && rm -rf ${TESTDIR}
}

@test "install from directory" {
  set -eu -o pipefail
  echo "# ddev add-on get ${DIR} with project ${PROJNAME} in $(pwd)" >&3
  run ddev add-on get "${DIR}"

  # Set the example cron job as an actual cron job.
  mv ./.ddev/web-build/time.cron.example ./.ddev/web-build/time.cron

  run ddev restart -y
  assert_success

  # The example runs every minute so we should wait at least the length.
  sleep 61

  # Check service works
  health_checks

  # Check example cron job works
  time_cron_checks
}

# bats test_tags=release
@test "install from release" {
  set -eu -o pipefail
  echo "# ddev add-on get ${GITHUB_REPO} with project ${PROJNAME} in $(pwd)" >&3
  run ddev add-on get "${GITHUB_REPO}"

  # Set the example cron job as an actual cron job.
  mv ./.ddev/web-build/time.cron.example ./.ddev/web-build/time.cron

  run ddev restart -y
  assert_success

  # The example runs every minute so we should wait at least the length.
  sleep 61

  # Check service works
  health_checks

  # Check example cron job works
  time_cron_checks
}

@test "services work when no valid jobs are present" {
  set -eu -o pipefail
  echo "# ddev add-on get ${DIR} with project ${PROJNAME} in $(pwd)" >&3
  run ddev add-on get "${DIR}"
  assert_success
  run ddev restart -y
  assert_success

  # We should wait at least one cycle.
  sleep 61

 # Check service works
  health_checks
}
