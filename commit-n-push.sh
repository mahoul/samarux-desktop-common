#!/bin/bash

SPEC_FILE="SPECS/$(basename $(pwd)).spec"

if [ $# -eq 1 ] && [ -s $SPEC_FILE ]; then

	COMMENT=$1

	rpmdev-bumpspec -c "$COMMENT" $SPEC_FILE
	git add .
	git commit -m "$COMMENT"
	git push

fi

