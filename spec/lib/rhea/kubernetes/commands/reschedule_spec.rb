require 'spec_helper'

describe Rhea::Kubernetes::Commands::Reschedule, :vcr do
  include KubernetesSpecHelper

  before(:each) { delete_replication_controllers }
  after(:each) { delete_replication_controllers }

  describe '#perform' do
    context 'an existing rc' do
      let(:process_count) { 2 }

      before :each do
        Rhea::Kubernetes::Commands::Scale.new(command_expression, process_count).perform
      end

      it 'reschedules the rc' do
        described_class.new(command_expression).perform
        replication_controller = Rhea::Kubernetes::Commands::Get.new(command_expression).perform
        expected_replication_controller = OpenStruct.new(
          expression: command_expression,
          image: kube_image,
          process_count: process_count
        )
        expect(replication_controller.to_h).to include(expected_replication_controller.to_h)

        expect(WebMock).to have_requested(:post, "#{kube_authed_api_url}replicationcontrollers")
        expect(WebMock).to have_requested(:put, "#{kube_authed_api_url}replicationcontrollers/#{kube_replication_controller_name}").twice
      end
    end
  end
end
