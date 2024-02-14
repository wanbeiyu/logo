ifeq ($(OS),Windows_NT)
    RM = del /Q
    FIXPATH = $(subst /,\,$1)
    CONVERT = magick convert
	PYTHON = py
else
    RM = rm -f
    FIXPATH = $1
    CONVERT = convert
	PYTHON = python3
endif

POTRACE = potrace

# Intermediate files
TEMP_ICON_PNG = temp_icon.png
TEMP_STRING_PNG = temp_string.png
TEMP_SPACER_PNG = temp_spacer.png
TEMP_LOGO_PNG = temp_logo.png
TEMP_LOGO_PNM = temp_logo.pnm

# Input files
ICON_SVG = icon.svg
STRING_SVG = string.svg

# Output files
ICON_PNG = icon.png
LOGO_SVG = logo.svg
LOGO_WHITE_SVG = logo-white.svg

.PHONY: all clean

all: clean $(ICON_PNG) $(LOGO_SVG) $(LOGO_WHITE_SVG)

clean:
	$(RM) \
	    $(call FIXPATH,$(TEMP_ICON_PNG)) \
	    $(call FIXPATH,$(TEMP_STRING_PNG)) \
	    $(call FIXPATH,$(TEMP_SPACER_PNG)) \
	    $(call FIXPATH,$(TEMP_LOGO_PNG)) \
	    $(call FIXPATH,$(TEMP_LOGO_PNM)) \
	    $(call FIXPATH,$(LOGO_SVG)) \
	    $(call FIXPATH,$(LOGO_WHITE_SVG))

$(TEMP_ICON_PNG): $(ICON_SVG)
	$(CONVERT) $< -resize 1000x1000 $@

$(ICON_PNG): $(TEMP_ICON_PNG)
	$(CONVERT) -size 1200x1200 xc:white \( $< -resize 844x1000 \) -gravity center -composite $@

$(TEMP_STRING_PNG): $(STRING_SVG)
	$(CONVERT) $< -resize 3000x3000 $@

# Create a spacer PNG
$(TEMP_SPACER_PNG):
	$(CONVERT) -size 200x1 xc:white $@

# Combine the PNGs into a single image
$(TEMP_LOGO_PNG): $(TEMP_ICON_PNG) $(TEMP_SPACER_PNG) $(TEMP_STRING_PNG)
	$(CONVERT) $^ -gravity center -background white +append $@

$(TEMP_LOGO_PNM): $(TEMP_LOGO_PNG)
	$(CONVERT) $< $@

$(LOGO_SVG): $(TEMP_LOGO_PNM)
	$(POTRACE) $< -s -o $@

$(LOGO_WHITE_SVG): $(LOGO_SVG)
	$(PYTHON) -c "import sys, re; sys.stdout.write(re.sub(r'(?i)#000000', '#ffffff', open('$(call FIXPATH,$<)').read()))" > $@
