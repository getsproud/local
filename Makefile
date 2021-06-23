PROJECTS = api-gateway auth-microservice brownbag-microservice budget-microservice category-microservice company-microservice department-microservice email-microservice employee-microservice feedback-microservice local helm-chart react-app
UTILS = toolbelt docs default-backend
UNAME := $(shell uname)

.PHONY: projects install utils clean

install:
		#install helm
		curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
		chmod 700 get_helm.sh
		./get_helm.sh
		rm get_helm.sh

ifeq ($(UNAME),Darwin)
		#install Skaffold
		curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-darwin-amd64 && \
		sudo install skaffold /usr/local/bin/
		rm skaffold

		#install kubectl
		brew install kubernetes-cli
else
		#install Skaffold
		curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64 && \
		sudo install skaffold /usr/local/bin/
		rm skaffold

		#install kubectl
		sudo apt-get update && sudo apt-get install -y apt-transport-https
		curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
		echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
		sudo apt-get update
		sudo apt-get install -y kubectl
endif

--clone:
	@for v in $(PROJECTS) ; do \
		echo Cloning $$v ... ; \
    git clone git@github.com:getsproud/$$v.git 2> /dev/null || echo $$v already exists. Skipping.; \
  done

utils: ## Checkout sproud. utils
	@for v in $(UTILS) ; do \
		echo Cloning $$v ... ; \
    git clone git@github.com:getsproud/$$v.git 2> /dev/null || echo $$v already exists. Skipping.; \
  done
	@for v in $(UTILS) ; do \
		rm -rf sproud-$$v ; \
	 	mv -f $$v sproud-$$v ; \
	done

projects: --clone ## Checkout sproud. project
	@for v in $(PROJECTS) ; do \
		rm -rf sproud-$$v ; \
	 	mv -f $$v sproud-$$v ; \
	done

clean: ## Delete sproud. from local space
	@for v in $(PROJECTS) ; do \
		echo Removing $$v ... ; \
		rm -rf sproud-$$v || echo $$v doesnt exist. Skipping.; \
	done
	@for v in $(UTILS) ; do \
		echo Removing $$v ... ; \
		rm -rf sproud-$$v || echo $$v doesnt exist. Skipping.; \
	done

commit-all: ## Commit all projects
	@for v in $(PROJECTS) ; do \
		echo Commiting changes of $$v ... ; \
		cd ../sproud-$$v && git add . && git commit -m ':construction_worker: ci(workflow): add ci worklflow' --no-verify  &&  git push 2> /dev/null || echo $$v nothing to commit. Skipping.; \
  done


.PHONY: help
help: ## Display this help screen
		@grep -h -E '^[a-z0-9A-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
