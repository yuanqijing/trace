
# build the docker env images
.PHONY: build
build:
	@for dir in `ls -l | grep ^d | awk '{print $$9}'`; do \
		if [ -f $$dir/Makefile ]; then \
			echo "building $$dir"; \
			$(MAKE) -C $$dir build; \
		fi; \
	done
