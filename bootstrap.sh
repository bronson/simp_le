#!/bin/sh -xe

run () {
  if [[ $EUID -ne 0 ]]; then
    if [ -z "$run_has_warned" ]; then
      echo 'Run these commands as root:'
      run_has_warned=1
    fi
  fi

  echo "$@"

  if [[ $EUID -eq 0 ]]; then
    "$@"
  fi
}

# keep in sync with .travis.yml
bootstrap_deb () {
  run apt-get update

  # virtualenv binary can be found in different packages depending on
  # distro version (don't need root to run `apt-cache show`)
  virtualenv_bin_pkg="virtualenv"
  if ! apt-cache show -qq "${virtualenv_bin_pkg}" >/dev/null 2>&1; then
    virtualenv_bin_pkg="python-virtualenv"
  fi

  run apt-get install -y --no-install-recommends \
    ca-certificates \
    gcc \
    libssl-dev \
    libffi-dev \
    python \
    python-dev \
    "${virtualenv_bin_pkg}"
}

bootstrap_rpm () {
  installer=$(command -v dnf || command -v yum)
  run "${installer?}" install -y \
    ca-certificates \
    gcc \
    libffi-devel \
    openssl-devel \
    python \
    python-devel \
    python-virtualenv
}

if [ -f /etc/debian_version ]
then
  bootstrap_deb
elif [ -f /etc/redhat-release ]
then
  bootstrap_rpm
else
  echo "Don't know how to bootstrap your platform."
fi
