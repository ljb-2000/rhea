require 'spec_helper'

describe Rhea::Kubernetes::Commands::Export, :vcr do
  include KubernetesSpecHelper

  before(:each) { delete_replication_controllers }
  after(:each) { delete_replication_controllers }

  describe '#perform' do
    context 'an existing rc' do
      let(:process_count) { 1 }

      before :each do
        Rhea::Kubernetes::Commands::Scale.new(command_expression, process_count).perform
      end

      it 'returns the data' do
        data = described_class.new.perform
        expect(data[:version]).to eq(Rhea::VERSION)
        expect(data[:created_at]).to be_a(Time)
        expect(data[:commands]).to eq([
          {
            expression: command_expression,
            image: kube_image,
            process_count: process_count
          }
        ])
      end
    end
  end
end
