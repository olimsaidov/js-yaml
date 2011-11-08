.SILENT: test test-functional test-issues


PATH := ./node_modules/.bin:${PATH}

PROJECT =  $(notdir ${PWD})
TMP_DIR = /tmp/${PROJECT}-$(shell date +%s)

REMOTE_NAME ?= origin
REMOTE_REPO ?= $(shell git config --get remote.${REMOTE_NAME}.url)


test: test-functional test-issues

test-issues:
	echo 
	echo "## ISSUES ######################################################################"
	echo "################################################################################"
	echo 
	node ./test/issues/run.js
	echo 

test-functional:
	echo 
	echo "## FUNCTIONAL ##################################################################"
	echo "################################################################################"
	echo 
	node ./test/functional/run.js
	echo 


build: browserify uglify

browserify:
	if test ! `which browserify` ; then npm install browserify ; fi
	browserify index.js -o js-yaml.js

uglify:
	if test ! `which uglifyjs` ; then npm install uglify-js ; fi
	uglifyjs js-yaml.js > js-yaml.min.js


gh-pages:
	@if test -z ${REMOTE_REPO} ; then \
		echo 'Remote repo URL not found' >&2 ; \
		exit 128 ; \
		fi
	mkdir ${TMP_DIR}
	cp -r index.html js-yaml.js demo ${TMP_DIR}
	touch ${TMP_DIR}/.nojekyll
	cd ${TMP_DIR} && \
		git init && \
		git add . && \
		git commit -q -m 'Recreated docs'
	cd ${TMP_DIR} && \
		git remote add remote ${REMOTE_REPO} && \
		git push --force remote +master:gh-pages 
	rm -rf ${TMP_DIR}
