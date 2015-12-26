require 'spec_helper'

describe Rhea::Kubernetes::Commands::Import, :vcr do
  include KubernetesSpecHelper

  before(:each) { delete_replication_controllers }
  after(:each) { delete_replication_controllers }

  describe '#perform' do
    context 'no existing rcs' do
      let(:process_count) { 1 }
      let(:data) do
        {
          version: Rhea::VERSION,
          created_at: Time.now,
          commands: [
            {
              expression: command_expression,
              image: kube_image,
              process_count: process_count
            }.stringify_keys
          ]
        }.stringify_keys
      end

      it 'creates the rcs' do
        described_class.new(data).perform
        replication_controllers = Rhea::Kubernetes::Commands::All.new.perform
        expected_replication_controller = OpenStruct.new(
          expression: command_expression,
          image: kube_image,
          process_count: process_count
        )
        expect(replication_controllers.length).to eq(1)
        expect(replication_controllers[0].to_h).to include(expected_replication_controller.to_h)
      end
    end
  end
end
