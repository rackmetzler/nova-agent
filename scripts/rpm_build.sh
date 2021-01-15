#!/bin/sh

function error_and_exit() {
    echo "ERROR: $1";
    exit 1;
}

if [ ! -f /.dockerenv ]; then
    error_and_exit "This should be run inside docker"
fi

if [ $# -ne 1 ]; then
  echo "syntax:  $0 <git_tag_id>"
  exit 1
fi

yum install -y git rpm-build python3-devel || error_and_exit "installing git rpm-build python3-devel"

rm -Rf /source/rpmbuild/
mkdir -p /source/rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS} || error_and_exit "creating rpmbuild dir structure"
cd /source
echo "TAG NAME: " $1
git archive --format=tgz --prefix nova-agent-$1/ -o /source/rpmbuild/SOURCES/nova-agent.tar.gz $1 || error_and_exit "getting tag archive $1"
export TAG_NAME=$1
rpmbuild --define "_topdir /source/rpmbuild" -bb /source/scripts/nova-agent.spec || error_and_exit "rpmbuild"
