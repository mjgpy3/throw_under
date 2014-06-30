require './lib/queue_binder.rb'
require 'bunny'

describe QueueBinder do

  let(:connection) { double('connection').as_null_object }
  let(:channel) { double('channel').as_null_object }

  before(:each) do
    allow(Bunny).to receive(:new).and_return(connection)
    allow(connection).to receive(:create_channel).and_return(channel)
  end

  describe '#initialize' do
    subject { QueueBinder.new(configurator) }

    context 'when given a Configurator' do
      let(:configurator) { double('Configurator', rabbit_url: 'some_url...', routing_suffix: 'foobar') }

      it { is_expected.to be_instance_of(QueueBinder) }

      it 'creates a new connection using the Configurator\'s rabbit url' do
        expect(Bunny).to receive(:new).with(configurator.rabbit_url)
        subject
      end

      it 'starts that new connection' do
        expect(connection).to receive(:start)
        subject
      end

      it 'creates a new channel using that new connection' do
        expect(connection).to receive(:create_channel)
        subject
      end

      it 'creates a new fanout using that new channel' do
        expect(channel).to receive(:fanout)
        subject
      end

      it 'creates a new fanout, binding it to the routing suffix' do
        expect(channel).to receive(:fanout).with(configurator.routing_suffix)
        subject
      end
    end

    describe '#bind_queues' do
      subject { QueueBinder.new(configurator).bind_queues }

    end
  end
end
