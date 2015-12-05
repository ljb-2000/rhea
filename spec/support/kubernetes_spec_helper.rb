module KubernetesSpecHelper
  extend RSpec::SharedContext

  let(:kube_user) { 'vagrant' }
  let(:kube_password) { 'vagrant' }
  let(:kube_api_host) { 'kube.local' }
  let(:kube_namespace) { 'default' }
  let(:kube_authed_api_url) { "https://#{kube_user}:#{kube_password}@#{kube_api_host}/api/v1/namespaces/#{kube_namespace}/" }
  let(:kube_env_vars) { { 'MY_ENV_VAR_NAME' => 'my_env_var_value' } }
  let(:kube_image) { 'docker.local/myimage:latest' }
  let(:kube_replication_controller_name) { 'rhea-7370-foo-bar' }

  let(:command_expression) { 'foo -bar' }

  before :each do
    Rhea.settings.merge!({
      default_command_type_key: 'sidekiq',
      env_vars: kube_env_vars,
      kube_api: {
        options: {
          auth_options: { user: kube_user, password: kube_password },
          ssl_options: { verify_ssl: OpenSSL::SSL::VERIFY_NONE }
        },
        url: "https://#{kube_api_host}/api/"
      },
      image: kube_image
    })
  end

  def delete_replication_controllers
    @api ||= Rhea::Kubernetes::Api.new
    controllers = @api.get_replication_controllers
    controllers.each do |controller|
      name = controller.metadata.name
      next unless name.start_with?('rhea-')
      @api.delete_replication_controller(controller.metadata.name, kube_namespace)
    end
  end

  def hash_includes_hash?(parent_hash, child_hash)
    parent_hash.merge(child_hash) == parent_hash
  end
end
