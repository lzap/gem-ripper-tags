#!/bin/bash
rm gem-ripper-tags*.gem; gem build gem-ripper-tags.gemspec && gem install -f gem-ripper-tags-*.gem && gem ripper
