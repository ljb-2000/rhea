require 'spec_helper'

describe Rhea::Kubernetes::Commands::All, :vcr do
  include KubernetesSpecHelper

  before(:each) { delete_replication_controllers }
  after(:each) { delete_replication_controllers }

  describe '#perform' do
    context 'an existing rc' do
      let(:process_count) { 1 }

      before :each do
        Rhea::Kubernetes::Commands::Scale.new(command_expression, process_count).perform
      end

      it 'returns the rc' do
        replication_controllers = Rhea::Kubernetes::Commands::All.new.perform
        expected_replication_controller = OpenStruct.new(
          expression: command_expression,
          image: kube_image.split('/').last,
          process_count: process_count
        )
        expect(replication_controllers.length).to eq(1)
        expect(replication_controllers[0].to_h).to include(expected_replication_controller.to_h)
      end
    end
  end
end
