require 'spec_helper'

describe Rhea::Kubernetes::Commands::Delete, :vcr do
  include KubernetesSpecHelper

  before(:each) { delete_replication_controllers }
  after(:each) { delete_replication_controllers }

  describe '#perform' do
    context 'an existing rc' do
      before :each do
        Rhea::Kubernetes::Commands::Scale.new(expression: command_expression, process_count: 1).perform
      end

      it 'deletes the rc' do
        described_class.new(expression: command_expression).perform
        url = "#{kube_authed_api_url}replicationcontrollers/#{kube_replication_controller_name}"
        expect(WebMock).to have_requested(:delete, url)
      end
    end
  end
end
