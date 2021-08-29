test:
	vusted --shuffle
.PHONY: test

doc:
	rm -f ./doc/piemenu.nvim.txt ./README.md
	nvim --headless -i NONE -n +"lua dofile('./spec/lua/piemenu/doc.lua')" +"quitall!"
	cat ./doc/piemenu.nvim.txt ./README.md
.PHONY: doc
