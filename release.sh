#!/bin/bash
#
# Before running this make sure you tagged and pushed!
#

VERSION=$(git describe --abbrev=0 --tags)
git checkout $VERSION && \
gem build gem-ripper-tags.gemspec && \
gem push gem-ripper-tags-$VERSION.gem && \
git checkout master
