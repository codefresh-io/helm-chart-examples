# chart-of-charts

This is an example of a "chart of charts" or "environment" chart. Deploying this chart will automatically deploy all charts found in the special `charts/` directory.

Additionally, you will notice that each of the subcharts (`app1`, `app2`, `app3`) do not contain a `templates/` directory. This is because these charts are all dependent on the `common/simplepod` chart.

This approach is valid/useful so long as each of your apps are all deployed the same way. The `common/simplepod` chart defines how all of your apps deployed, and you only need to make changes there.

In terms of differeniating the chart between each app, you may wish to, for example, keep everything the same except for a Docker image tied to that specific app. In this example (taken from [charts/app1/values.yaml](https://github.com/codefresh-io/helm-chart-examples/blob/master/chart-of-charts/charts/app1/values.yaml)), we are simply changing the message text that the pod will echo every 5 seconds:

```
simplepod:
    parent: "app1"
    message: "hello from app1"
```

Note: The `simplepod.parent` key above is used in order to differentiate the name of the pod betwen apps. This is due to the inability for Helm to determine the name of a parent chart at time of install. Please see https://github.com/helm/helm/issues/2506 for more info.

## Gathering Dependencies

In order to vendor the `common/simplepod` chart into each of the subcharts in `charts/`, run the following script:

```
for d in $(find charts/ -type d -mindepth 1 -maxdepth 1); do
    (cd $d && helm dep up)
done
```

You will notice this will result in creating `requirements.lock` and `charts/simplepod-1.0.0.tgz` in each of the subchart directories.

## Installing the chart

After gathering dependencies, install this just like any other chart, passing values file overrides if necessary:

```
helm install . --name myrelease -f ./override-values.yaml
```

Output:

```
NAME:   myrelease
LAST DEPLOYED: Mon Jul 30 15:01:58 2018
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/Pod
NAME                      READY  STATUS             RESTARTS  AGE
myrelease-simplepod-app1  0/1    ContainerCreating  0         0s
myrelease-simplepod-app2  0/1    ContainerCreating  0         0s
myrelease-simplepod-app3  0/1    ContainerCreating  0         0s
```

## Codefresh Pipeline

Please see [codefresh.yml](https://github.com/codefresh-io/helm-chart-examples/blob/master/chart-of-charts/codefresh.yml) for an example pipeline to deploy this chart.

You are also required to set the `KUBE_CONTEXT` variable, either in the YAML, or via Codefresh UI, set to the name of one of your attached clusters.
