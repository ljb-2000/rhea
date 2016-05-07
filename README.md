Rhea
=====
A web UI for managing a Kubernetes cluster

Overview
--------

Rhea is a web UI for managing a Kubernetes cluster. It makes it very easy to:

* Create and manage replication controllers that run arbitrary commands
* Perform actions on multiple replication controllers
* Export/import the state of the cluster's replication controllers
* View pods' statuses on all nodes
* View the cluster's events

Installation
------------

Rhea is a Rails engine. To install it, include it in your `Gemfile`:

```ruby
gem 'rhea'
```

Mount it in `routes.rb`:

```ruby
mount Rhea::Engine => '/rhea'
```

And configure it in `config/initializers/rhea.rb`:

```ruby
require 'rhea'

Rhea.configure do |config|
  config.kube_api = {
    options: {
      ssl_options: {
        client_key: OpenSSL::PKey::RSA.new(Rails.root.join(ENV['KEYS_DIRECTORY'], 'apiserver-key.pem').read),
        client_cert: OpenSSL::X509::Certificate.new(Rails.root.join(ENV['KEYS_DIRECTORY'], 'apiserver.pem').read),
        ca_file: Rails.root.join(ENV['KEYS_DIRECTORY'], 'ca.pem').to_s,
        verify_ssl: OpenSSL::SSL::VERIFY_PEER
      }
    },
    url: 'https://kubernetes.example.com/api/'
  }
  config.default_image = 'docker.registry.com/myworker:latest'
end
```

Configuration
-------------

See [Installation](#installation) for basic configuration.

### Options

#### kube_api

The API options. These are simply passed to [kubeclient](https://github.com/abonas/kubeclient), so anything that's valid in `kubeclient` is valid here. Here's an example:

```ruby
config.kube_api = {
  options: {
    ssl_options: {
      client_key: OpenSSL::PKey::RSA.new(Rails.root.join(ENV['KEYS_DIRECTORY'], 'apiserver-key.pem').read),
      client_cert: OpenSSL::X509::Certificate.new(Rails.root.join(ENV['KEYS_DIRECTORY'], 'apiserver.pem').read),
      ca_file: Rails.root.join(ENV['KEYS_DIRECTORY'], 'ca.pem').to_s,
      verify_ssl: OpenSSL::SSL::VERIFY_PEER
    }
  },
  url: 'https://kubernetes.example.com/api/'
}
```

#### command_types

Command types are custom templates that let you create commands more easily. They can be used in the command creation form. `$INPUT` is the value that's passed in from the form input.

```ruby
config.command_types = [
  {
    key: 'default',
    name: 'Default',
    format: '$INPUT'
  },
  {
    key: 'sidekiq',
    name: 'Sidekiq',
    format: 'sidekiq -q $INPUT'
  },
  {
    key: 'resque',
    name: 'Resque',
    format: 'QUEUES=$INPUT rake resque:work'
  },
  {
    key: 'goworker',
    name: 'goworker',
    format: 'worker.go -q $INPUT'
  }
]
```

#### container_options

By default, each pod has a single, minimally-configured container. You can easily configure additional container options, which will be merged into the pod's `spec.template.spec.containers[0]`.

```ruby
config.container_options = {
  'resources' => {
    'requests' => {
      'memory' => '256Mi',
      'cpu' => '250m'
    },
    'limits' => {
      'memory' => '512Mi',
      'cpu' => '1000m'
    }
  }
}
```

#### default_command_type_key

This will be used to set the default command type when creating new commands.

```ruby
config.default_command_type_key = 'goworker'
```

#### default_image

This will be used to set the default image when creating new commands.

```ruby
config.default_image = 'docker.registry.com/myworker:latest'
```

#### env_vars

This will be used to set custom environment variables in pods scheduled by Rhea.

```ruby
config.env_vars = {
  'FOO' => 'bar'
}
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
