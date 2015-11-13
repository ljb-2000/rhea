Rhea
=====
A web UI for managing a Kubernetes cluster

Overview
--------

Rhea is a web UI for managing a Kubernetes cluster. It's a Rails engine; see miner's `initializers/rhea.rb` to see how to configure it.

Testing
-------

To write tests that communicate with a Kubernetes cluster, you'll want to have a Kubernetes cluster running locally at https://vagrant:vagrant@kube.local. VCR is used to record HTTP requests and responses.

"Rhea"?
-------

Rhea is a Greek Titan associated with ease, comfort, and fertility. In her 21st century gem form, she lets you easily and comfortably birth many Kubernetes pods.

License
-------

Rhea is released under the MIT License. Please see the MIT-LICENSE file for details.
