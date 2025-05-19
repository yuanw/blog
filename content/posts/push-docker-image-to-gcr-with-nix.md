---
title: Push Nix-built container image to GCR using github action
description: use skopeo to push nix-built docker image to google container registry
tags: 
  - nix
  - github
  - skopeo 
date: 2021-02-07
---

# Intro 
I have been trying out google cloud run with a simple haskell + purescript web app. In order to deploy the app, I need to containerize the app and push the docker image to google container registry. I wanted to figure out whether this can be done with nix and some simple github actions. Turns out: with [skopep](https://github.com/containers/skopeo), it is pretty easy!


# skopeo copy
After some searching, I found this discourse [thread](https://discourse.nixos.org/t/push-docker-tgz-images-to-registry-directly/189) mentions `skopeo`, and I found this [repo](https://github.com/wagdav/thewagner.net) using `nix flakes` and `skopeo` to push docker image into a private docker registry in github action. So I decided to try out skopeo.

skopeo can push an image from one location to another. It supports Google Container Registry (GCR)

So we can push our image like this
```
skopeo copy docker-image://$(nix-build -A my-image --no-out-link) docker://gcr.io/google-cloud-project-name/service:tag
```

# install skopeo in github action

I am using [install-nix-action](https://nix.dev/tutorials/continuous-integration-github-actions#github-actions) in my build step already, so I added a shell script bin in my nix flake, and make it as nix flake app using [flakes-utils](https://github.com/numtide/flake-utils#mkapp--drv-name--drvpname-or-drvname-exepath--drvpassthruexepath-or-binname), which can be run using `nix run ".#script"`

```nix
upload-script = pkgs.writeShellScriptBin "upload-image" ''
    set -eu
    OCI_ARCHIVE=$(nix-build --no-out-link)
    DOCKER_REPOSITORY="docker://gcr.io/$GOOGLE_CLOUD_PROJECT_NAME/$GOOGLE_CLOUD_RUN_SERVICE_NAME:$GITHUB_SHA"
    ${pkgs.skopeo}/bin/skopeo copy --dest-creds="_json_key:$GCR_DEVOPS_SERVICE_ACCOUNT_KEY"     "docker-archive:$OCI_ARCHIVE" "$DOCKER_REPOSITORY"
'';
```

```
apps.upload-script = flake-utils.lib.mkApp { drv = upload-script; };
```


# Authenticate skopeo with GCR

I was not able to find too much documentation on this step. So I went to some trail and error. 

GCR supports different authentication [methods](https://cloud.google.com/container-registry/docs/advanced-authentication#json-key). I thought the easiest would to create a service account key with Cloud Storage Admin role, and upload the key content as a secret in github actions.

```
docker login -u _json_key -p "$(cat keyfile.json)" https://HOSTNAME
```

Of course, we want to replace `docker` with `skopeo`. This works locally, but not in github action due to how `skope login` [works](https://learn.redhat.com/t5/Red-Hat-Learning-Subscription/Skopeo-Permission-on-run-Directory/td-p/17598).

But turns out, we don't have to do `skope login`, we can just using `skopeo copy --dest-creds`.

# Put everything together

So I put my service account key, google cloud project name, and the name of the GCR docker image name into github actions as secret, and pass them as env variable in the step, and do `nix run ".#upload-script"`

```yaml
name: CI

on: [push, pull_request]

jobs:
  build:
    name: Build
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2.4.0
    - uses: cachix/install-nix-action@v16
      with:
        extra_nix_config: |
          access-tokens = github.com=${{ secrets.GITHUB_TOKEN }}
    - name: Push Image
      run: |
        nix run ".#upload-script"
      env:
        GCR_DEVOPS_SERVICE_ACCOUNT_KEY: ${{ secrets.GCR_DEVOPS_SERVICE_ACCOUNT_KEY }}
        GOOGLE_CLOUD_PROJECT_NAME: ${{ secrets.GOOGLE_CLOUD_PROJECT_NAME }}
        GOOGLE_CLOUD_RUN_SERVICE_NAME: ${{ secrets.GOOGLE_CLOUD_RUN_SERVICE_NAME}}
      if: github.ref == 'refs/heads/master'
```

Works like a charm. Thanks for reading

# References
- [An example using skopeo to push to docker registry in github actions ](https://github.com/wagdav/thewagner.net/blob/main/scripts/push_image.sh)
- [nix discourse thread on push docker registry](https://discourse.nixos.org/t/push-docker-tgz-images-to-registry-directly/189)
- [skopeo copy manpage](https://github.com/containers/skopeo/blob/main/docs/skopeo-copy.1.md)
