require 'spec_helper'

describe Rhea::Kubernetes::Commands::Redeploy, :vcr do
  include KubernetesSpecHelper

  before(:each) { delete_replication_controllers }
  after(:each) { delete_replication_controllers }

  describe '#perform' do
    context 'an existing rc' do
      let(:process_count) { 2 }

      before :each do
        Rhea::Kubernetes::Commands::Scale.new(command, process_count).perform
      end

      it 'redeploys the rc' do
        Rhea::Kubernetes::Commands::Redeploy.new(command).perform
        replication_controller = Rhea::Kubernetes::Commands::Get.new(command).perform
        expected_replication_controller = OpenStruct.new(
          expression: command,
          image: kube_image.split('/').last,
          process_count: process_count
        )
        expect(replication_controller.to_h).to include(expected_replication_controller.to_h)

        # One POST for the initial creation, and a second POST for the recreation
        expect(WebMock).to have_requested(:post, "#{kube_authed_api_url}replicationcontrollers").twice
        expect(WebMock).to have_requested(:delete, "#{kube_authed_api_url}replicationcontrollers/#{kube_replication_controller_name}")
        expect(WebMock).to have_requested(:put, "#{kube_authed_api_url}replicationcontrollers/#{kube_replication_controller_name}")
      end
    end
  end
end
