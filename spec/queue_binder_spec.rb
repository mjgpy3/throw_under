require './lib/queue_binder.rb'
require 'bunny'

describe QueueBinder do

  before(:each) do
    allow(Bunny).to receive(:new)
  end

  describe '#initialize' do
    subject { QueueBinder.new(configurator) }

    context 'when given a Configurator' do
      let(:configurator) { double('Configurator', rabbit_url: 'some_url...') }

      it { is_expected.to be_instance_of(QueueBinder) }

      it 'creates a new connection using the Configurator\'s rabbit url' do
        expect(Bunny).to receive(:new).with(configurator.rabbit_url)
        subject
      end
    end

    describe '#bind_queues' do
      subject { QueueBinder.new(configurator).bind_queues }

    end
  end
end
