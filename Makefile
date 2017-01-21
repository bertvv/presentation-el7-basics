## Presentation makefile

OUTPUT := gh-pages

# Directory for reveal.js
REVEAL_JS_DIR := $(OUTPUT)/reveal.js

# File name of the reveal.js tarball
REVEAL_JS_TAR := 3.4.0.tar.gz

# Download URL
REVEAL_JS_URL := https://github.com/hakimel/reveal.js/archive/$(REVEAL_JS_TAR)


## Presentation
$(OUTPUT)/index.html: basic-commands-el7.md $(REVEAL_JS_DIR)
	pandoc \
		--standalone \
		--to=revealjs \
		--template=default.revealjs \
		--variable=theme:white \
		--highlight-style=zenburn \
		--output $@ $<

# Highlight styles: espresso or zenburn (not enough contrast in the others)
# Theme: black, moon, night

## Download and install reveal.js locally
$(REVEAL_JS_DIR):
	wget $(REVEAL_JS_URL)
	tar xzf $(REVEAL_JS_TAR)
	rm $(REVEAL_JS_TAR)
	mv -T reveal.js* $(REVEAL_JS_DIR)

## Cleanup
clean:
	rm -f $(OUTPUT)/*.html
	rm -f $(OUTPUT)/*.pdf

## Thorough cleanup (also removes reveal.js)
mrproper: clean
	rm -rf $(OUTPUT)

all: $(OUTPUT)/index.html

handouts.pdf: basic-commands-el7.md.md
	pandoc --variable mainfont="DejaVu Sans" \
		--variable monofont="DejaVu Sans Mono" \
		--variable fontsize=11pt \
		--variable geometry:margin=1.5cm \
		-f markdown  $< \
		--latex-engine=lualatex \
		-o $@

