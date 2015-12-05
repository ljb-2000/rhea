require 'spec_helper'

describe Rhea::Kubernetes::Commands::Scale, :vcr do
  include KubernetesSpecHelper

  before(:each) { delete_replication_controllers }
  after(:each) { delete_replication_controllers }

  let(:process_count) { 2 }

  describe '#perform' do
    context 'no existing rc' do
      it 'creates an rc' do
        Rhea::Kubernetes::Commands::Scale.new(command_expression, process_count).perform
        matches = -> (request) do
          data = ActiveSupport::JSON.decode(request.body)
          container = data['spec']['template']['spec']['containers'][0]
          expected_container = {
            'command' => command_expression.split(' '),
            'image' => kube_image,
            'name' => kube_replication_controller_name,
            'env' => kube_env_vars.map { |name, value| { 'name' => name, 'value' => value } }
          }
          hash_includes_hash?(container, expected_container)
        end
        url = "#{kube_authed_api_url}replicationcontrollers"
        expect(WebMock).to have_requested(:post, url).with { |request| matches.call(request) }
      end
    end
  end
end
