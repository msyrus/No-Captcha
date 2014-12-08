all: lib/index.js

clean:
	rm lib/index.js

lib/%.js: %.iced
	iced -p -c $^ > $@