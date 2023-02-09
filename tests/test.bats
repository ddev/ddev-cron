setup() {
  set -eu -o pipefail

  export DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )/.."
  export TESTDIR=~/tmp/ddev-cron
  mkdir -p $TESTDIR
  export PROJNAME=ddev-cron
  export DDEV_NON_INTERACTIVE=true
  ddev delete -Oy ${PROJNAME} || true
  cd "${TESTDIR}"
  ddev config --project-name=${PROJNAME}
  ddev start -y
  echo "# ddev started at $(date)" >&3
}

teardown() {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  ddev delete -Oy ${PROJNAME}
  [ "${TESTDIR}" != "" ] && rm -rf ${TESTDIR}
}

@test "install from directory" {
  set -eu -o pipefail
  cd ${TESTDIR}
  echo "# ddev get ${DIR} with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev get ${DIR}
  ddev restart

  sleep 61
 # Make sure cron process is running
  ddev exec 'sudo killall -0 cron'
 # ASSERT: Make sure time.log got a line written to it.
  grep UTC time.log
}

#@test "install from release" {
#  set -eu -o pipefail
#  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
#  echo "# ddev get ddev/ddev-cron with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
#  ddev get ddev/ddev-cron
#  ddev restart
#
#  sleep 61
# # Make sure cron process is running
#  ddev exec 'sudo killall -0 cron'
# # ASSERT: Make sure time.log got a line written to it.
#  grep UTC time.log
#}
