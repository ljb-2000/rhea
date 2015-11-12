require 'spec_helper'

describe Rhea::Kubernetes::Commands::Delete, :vcr do
  include KubernetesSpecHelper

  before(:each) { delete_replication_controllers }
  after(:each) { delete_replication_controllers }

  describe '#perform' do
    context 'an existing rc' do
      before :each do
        Rhea::Kubernetes::Commands::Scale.new(command, 1).perform
      end

      it 'deletes the rc' do
        Rhea::Kubernetes::Commands::Delete.new(command).perform
        url = "#{kube_authed_api_url}replicationcontrollers/#{kube_replication_controller_name}"
        expect(WebMock).to have_requested(:delete, url)
      end
    end
  end
end
