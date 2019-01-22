# ops-drone


Allow you to deploy drone CI server + autoscaler + caddy for letsencrypt.

Caddy is an overkill, but is most easy way to setup drone and autoscaler endpoints on one host with ssl.

Example:


```
levant deploy -address=http://your-nomad-installation-or-cluster:4646 -var-file=vars.yaml caddy.nomad
levant deploy -address=http://your-nomad-installation-or-cluster:4646 -var-file=vars.yaml drone.nomad
levant deploy -address=http://your-nomad-installation-or-cluster:4646 -var-file=vars.yaml autoscaler.nomad
```
