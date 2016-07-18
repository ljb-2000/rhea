<h1><img src="docs/logo.png?raw=true" width="27" /> Rhea</h1>

A web UI for managing a Kubernetes cluster

Overview
--------

Rhea is a web UI for managing a Kubernetes cluster. It makes it very easy to:

* Create and manage replication controllers that run arbitrary commands
* Perform actions on multiple replication controllers
* Export/import the state of the cluster's replication controllers
* Monitor pods' statuses on all nodes
* Monitor the cluster's events

---

Create and manage replication controllers that run arbitrary commands:

[<img src="docs/commands.gif?raw=true" width="900" />](docs/commands.gif?raw=true)

Monitor the nodes' pods and the cluster's events:

[<img src="docs/nodes.png?raw=true" width="440" />](docs/nodes.png?raw=true)
[<img src="docs/events.png?raw=true" width="440" />](docs/events.png?raw=true)

Quick start
-----------

The included Dockerfile builds a container running a Rails app with Rhea.

1. Configure Rhea for your kube cluster with `rhea.yml` in the project path.
  - Sample config: `cp rhea.yml.example rhea.yml`
  - Config guide: See below and [kubeclient](https://github.com/abonas/kubeclient)
2. Build the container: `docker build -it rhea-rails .`
3. Run it: `docker run --rm -p 3000:3000 rhea-rails`

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

Development
---

Use the sample Rails app with Rhea.

1. `cd examples/rhea-rails`
2. Update the rhea Gem in the sample app's `Gemfile`:
  - `gem 'rhea', git: 'https://github.com/entelo/rhea.git'`
to
  - `gem 'rhea', path: '../../'`

3. Modify `config/rhea.yml` for your needs
4. `bundle install`
5. `rails server KUBE_API_URL=http://localhost:8080/api/`
6. Visit http://localhost:3000

Testing
-------

To write tests that communicate with a Kubernetes cluster, you'll want to have a Kubernetes cluster running locally at https://vagrant:vagrant@kube.local. VCR is used to record HTTP requests and responses.

"Rhea"?
-------

Rhea is a Greek Titan associated with ease, comfort, and fertility. In her 21st century gem form, she lets you easily and comfortably birth many Kubernetes pods.

License
-------

Rhea is released under the MIT License. Please see the MIT-LICENSE file for details.
