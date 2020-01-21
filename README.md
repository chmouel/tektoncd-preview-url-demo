# TektonCD Demo a preview URL on PR

This will demo a preview URL for PR changes. 

It installs a TektonCD Triggers Eventlistener to listen when new PR is created
and deploy a PipelineRun which would :

* comment-first: Set GitHUB Status and give a Tekton-Dashboard URL to follow the build
* build - build the Dockerfile, which has a simple golang web server based on [echo](https://echo.labstack.com/)  to server the static files.
* push - push the image to the openshfit internal registry
* deploy - deploy the imge to its own deployment (suffixed with the git sha
  commit of the change) and expose it publicaly with a route.
* comment-last - Post the URL back on the Github issue comment and set the status as successfull.

## Installs

Install TektonCD Pipelines and Triggers.

use the `install.sh` script on your cloud, it assumes you have your github token
set in your `/.gitconfig` as :

```ini
[github]
	oauth-token = TOKEN
```

Configure your webhook to push PR events to your eventlistenner route, get your endpoint url with :

```shell
https://$(oc get route el-preview-url -o jsonpath='{.spec.host}')
```

## Caveats

* No failure handling
* No cleanups ! (Can run out of resources quite quickly)

## Contacts

[@chmouel](https://twitter.com/chmouel)

![and now for something different](https://media0.giphy.com/media/3nbxypT20Ulmo/200_d.gif?cid=e1bb72ff6a16e0ad362f8fe5c3e3d3dd9d53bfcf0bfe8570&rid=200_d.gif)
