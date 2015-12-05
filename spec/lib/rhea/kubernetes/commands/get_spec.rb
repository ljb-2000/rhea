require 'spec_helper'

describe Rhea::Kubernetes::Commands::Get, :vcr do
  include KubernetesSpecHelper

  before(:each) { delete_replication_controllers }
  after(:each) { delete_replication_controllers }

  describe '#perform' do
    context 'an existing rc' do
      let(:process_count) { 1 }

      before :each do
        Rhea::Kubernetes::Commands::Scale.new(command_expression, process_count).perform
      end

      it 'gets the rc' do
        replication_controller = Rhea::Kubernetes::Commands::Get.new(command_expression).perform
        expected_replication_controller = OpenStruct.new(
          expression: command_expression,
          image: kube_image.split('/').last,
          process_count: process_count
        )
        expect(replication_controller.to_h).to include(expected_replication_controller.to_h)
      end
    end
  end
end
