#############################################################################
# PUBLISH GIT HUB PAGES
###############################################################################

gh-pages:
	git checkout gh-pages
	make pages

######################################################################
# ONLY RUN ON GH-PAGES
######################################################################

PROJECT=`basename $(PWD)`
DIR=/tmp/$(PROJECT)
DOC=$(DIR)/doc

pages: ghphtml ghpgit
	echo done

ghphtml:
	cd /tmp
	rm -rf $(DIR)
	cd /tmp; git clone git://github.com/kjtanaka/$(PROJECT).git
	cp $(DIR)/Makefile .
	cd $(DOC); ls; make html
	rm -fr _static
	rm -fr _source
	rm -fr *.html
	cp -r $(DOC)/_build/html/* .

ghpgit:
	git add . _sources _static   
	git commit -a -m "updating the github pages"
	git push
	git checkout master

