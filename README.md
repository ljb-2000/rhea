Rhea
=====
A web UI for managing a Kubernetes cluster

Overview
--------

Rhea is a web UI for managing a Kubernetes cluster. It makes it (very!) easy to:

* Create and manage replication controllers that run arbitrary commands
* View pods' statuses on all nodes
* View the cluster's events
* Export/import the state of the cluster's replication controllers

Configuration
-------------

Here's an example of how Rhea can be configured:

```ruby
# config/initializers/rhea.rb
require 'rhea'

Rhea.configure do |config|
  config.default_command_type_key = 'sidekiq'
  config.env_vars = {
    'RAILS_ENV' => Rails.env
  }
  config.kube_api = {
    options: {
      auth_options: { user: ENV['KUBERNETES_USER'], password: ENV['KUBERNETES_PASSWORD'] }
    },
    url: ENV['KUBERNETES_URL']
  }
  config.default_image = ENV['KUBERNETES_DEFAULT_IMAGE']
end
```

Testing
-------

To write tests that communicate with a Kubernetes cluster, you'll want to have a Kubernetes cluster running locally at https://vagrant:vagrant@kube.local. VCR is used to record HTTP requests and responses.

"Rhea"?
-------

Rhea is a Greek Titan associated with ease, comfort, and fertility. In her 21st century gem form, she lets you easily and comfortably birth many Kubernetes pods.

License
-------

Rhea is released under the MIT License. Please see the MIT-LICENSE file for details.
