.PHONY: compile

json:
	yq '.' opening-qs.yaml>opening-qs.json

compile: json
	# Go down into the 
	echo "Compiling..."
	cd ../../../../elm-flow && \
		make compile && \
		cp dist/elm-flow.js ../BraneShop.github.io/src/js
