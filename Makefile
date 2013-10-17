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
	cd /tmp; rm -rf $(DIR)
	cd /tmp; git clone git://github.com/kjtanaka/$(PROJECT).git
	cd $(DOC); make html
	rsync -av --exclude='_static' $(DOC)/_build/html/* .

ghpgit:
	git add . 
	git commit -am "updating the github pages"
	git push
	git checkout master
	git branch
