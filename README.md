<p align="center">
  <img width="240" src="sproud-logo.png">
</p>

## 👍 Requirements
The local development platform has an install script for Linux and Mac. Windows users have to install the required cli tools themselves. Get your VPN config from an admin and your kubeconfig from the [sproud. Rancher](rancher.sproud.dev)

- [nodejs](https://nodejs.org/)
- [git](https://git-scm.com/)
- [skaffold](https://skaffold.dev/)
- [helm](https://helm.sh/)
- [kubectl](https://kubernetes.io/de/docs/tasks/tools/)
- [kubeconfig](rancher.sproud.dev)
- sproudVPN

## ⭐ Install **sproud.** for development
For local development you need to clone this repository `(getsproud/local)` and run the following commands. *No worries, OS detection is inside the Makefile*
```
make install
make projects
```

## 🚀 Starting **sproud.** for local development
To spin up an development enviroment do folling steps.

- create new branch *[feature/123-foo-bar]*
- run `make develop PROJECT=foo-bar`

  *foo-bar must be a project folder withour the **sproud-** prefix*
- start coding 🤩


## 🤖 **sproud.** Make
What other commands is the Makefile capable of

**setup required cli tools**

```
make install
```

**start feature environment on cluster**

```
make develop PROJECT=foo
```

**setup sproud. all projects/microservices**

```
make projects
```

**setup sproud. single project/microservice**

```
make project PROJECT=foo
```

**setup sproud. utils (docs, toolbelt, ...)**

```
make utils
```

**show sproud. make help**

```
make help
```
