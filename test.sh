#!/bin/bash
rm gem-ripper-tags*.gem; gem build gem-ripper-tags.gemspec && gem uninstall gem-ripper-tags && gem install gem-ripper-tags-*.gem && gem ripper --debug
