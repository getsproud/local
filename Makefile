PROJECTS = api-gateway auth-microservice brownbag-microservice budget-microservice category-microservice company-microservice department-microservice email-microservice employee-microservice training-microservice feedback-microservice helm-chart react-app
UTILS = toolbelt docs default-backend
UNAME := $(shell uname)
DEVELOPMENT_PROJECTS = api-gateway auth-microservice brownbag-microservice budget-microservice category-microservice company-microservice department-microservice email-microservice employee-microservice training-microservice feedback-microservice react-app

.PHONY: projects install utils clean commit-all develop

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

		#install telepresence
		brew install datawire/blackbird/telepresence
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

		#install telepresence
		sudo curl -fL https://app.getambassador.io/download/tel2/linux/amd64/latest/telepresence -o /usr/local/bin/telepresence
		sudo chmod a+x /usr/local/bin/telepresence
endif

--clone:
	@for v in $(PROJECTS) ; do \
		echo Cloning $$v ... ; \
    git clone git@github.com:getsproud/$$v.git 2> /dev/null || echo $$v already exists. Skipping.; \
  done

--check-env:
ifndef SCOPE
	$(error SCOPE is undefined)
endif
ifndef MESSAGE
	$(error MESSAGE is undefined)
endif
--check-project:
ifndef PROJECT
	$(error PROJECT is undefined)
endif

utils: ## Checkout sproud. utils
	@for v in $(UTILS) ; do \
		echo Cloning $$v ... ; \
    git clone git@github.com:getsproud/$$v.git 2> /dev/null || echo $$v already exists. Skipping.; \
  done
	@for v in $(UTILS) ; do \
		rm -rf ../sproud-$$v ; \
	 	mv -f $$v ../sproud-$$v ; \
	done

projects: --clone ## Checkout sproud. project
	@for v in $(PROJECTS) ; do \
		rm -rf ../sproud-$$v ; \
	 	mv -f $$v ../sproud-$$v ; \
	done

project: --check-project ## Checkout sproud. single project/microservice. Needs PROJECT=
	echo Cloning $$PROJECT ...
	git clone git@github.com:getsproud/$$PROJECT.git 2> /dev/null || echo $$PROJECT already exists. Skipping.
	rm -rf ../sproud-$$PROJECT
	mv -f $$PROJECT ../sproud-$$PROJECT

clean: ## Delete sproud. from local space
	@for v in $(PROJECTS) ; do \
		echo Removing $$v ... ; \
		rm -rf ../sproud-$$v || echo $$v doesnt exist. Skipping.; \
	done
	@for v in $(UTILS) ; do \
		echo Removing $$v ... ; \
		rm -rf ../sproud-$$v || echo $$v doesnt exist. Skipping.; \
	done

commit-all: --check-env ## Commit all projects. Needs SCOPE= and MESSAGE= args
	@for v in $(PROJECTS) ; do \
		echo Commiting changes of $$v ... ; \
		cd ../sproud-$$v && git add . && git commit -m ':construction_worker: *($(SCOPE)): $(MESSAGE)' --no-verify  &&  git push 2> /dev/null || echo $$v nothing to commit. Skipping.; \
  done

feature: --check-project ## Spin up development enviroment PROJECT=
	@for v in $(PROJECTS) ; do \
		if [[ "$$v" !=  "$$PROJECT" ]]; then \
			$$(cd ../sproud-$$v && git checkout main | true && git pull | true) ; \
		fi \
	done

	. ./get-feature.sh ${PROJECT}; \
	echo "Starting development environment for feature $$FEATURE on sproud-$$PROJECT"; \
	kubectl config use-context sproud-dev-k8s; \
	kubectl create namespace sproud-feature-$$FEATURE; \
	kubectl annotate ns --overwrite=true sproud-feature-$$FEATURE field.cattle.io/projectId="c-5nj94:p-zjgp8"; \
	helm template ../sproud-helm-chart --set subdomain=$$FEATURE. --set redis.namespace=sproud-feature-$$FEATURE > helm-rendered.yaml; \
	skaffold dev -n sproud-feature-$$FEATURE --trigger=polling --cleanup=false;

.PHONY: help

help: ## Display this help screen
		@grep -h -E '^[a-z0-9A-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
