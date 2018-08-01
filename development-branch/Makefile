makefile_dir := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

.PHONY: helm/release-all
helm/release-all:
	@$(makefile_dir)/scripts/release-all.sh

.PHONY: helm/update-reqs
helm/update-reqs:
	@$(makefile_dir)/scripts/update-reqs.sh

.PHONY: helm/gather-deps
helm/gather-deps:
	@$(makefile_dir)/scripts/gather-deps.sh
