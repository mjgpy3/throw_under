require './lib/queue_binder.rb'

describe QueueBinder do

  describe '#initialize' do
    subject { QueueBinder.new(configurator) }

    context 'when given a Configurator' do
      let(:configurator) { double('Configurator') }

      it { is_expected.to be_instance_of(QueueBinder) }
    end
  end

end
