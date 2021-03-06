require 'spec_helper'

describe Rhea::Kubernetes::Commands::Get, :vcr do
  include KubernetesSpecHelper

  before(:each) { delete_replication_controllers }
  after(:each) { delete_replication_controllers }

  describe '#perform' do
    context 'an existing rc' do
      let(:process_count) { 1 }

      before :each do
        Rhea::Kubernetes::Commands::Scale.new(expression: command_expression, image: kube_image, process_count: process_count).perform
      end

      it 'gets the rc' do
        replication_controller = described_class.new(expression: command_expression).perform
        expected_attributes = {
          expression: command_expression,
          image: kube_image,
          process_count: process_count
        }
        expect(replication_controller.attributes).to include(expected_attributes)
      end
    end
  end
end
