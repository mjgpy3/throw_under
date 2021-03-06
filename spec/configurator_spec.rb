require './lib/configurator.rb'

def file_under_test
  __FILE__.sub('_spec', '').sub('spec', 'lib')
end

describe Configurator do
  let(:config) { {} }
  let(:more_values) { {} }
  let(:file_name) { 'config.tst.yaml' }

  before(:each) do
    File.open('./config/config.tst.yaml', 'w') { |file| file.write(YAML.dump(config.merge(more_values))) }
  end

  after(:each) do
    File.delete('./config/config.tst.yaml')
  end

  describe '#initialize' do
    before(:each) do
      allow(YAML).to receive(:load_file).and_return(double.as_null_object)
    end

    subject { Configurator.new(file_name) }
    let(:file_name) { 'some_file_name' }

    it { is_expected.to be_an_instance_of(Configurator) }

    it 'reads the passed filename from ../../config/' do
      expect(File).to receive(:expand_path).with('../../config/' + file_name, anything)
      subject
    end

    it 'expands the path based on a file in the directory one above the current' do
      expect(File).to receive(:expand_path).with(anything, file_under_test)
      subject
    end

    context 'when the config file exists' do
      let(:config_path) { 'path/to/config' }
      before(:each) do
        allow(File).to receive(:expand_path).and_return(config_path)
      end

      it 'loads the config file using YAML' do
        expect(YAML).to receive(:load_file).with(config_path)
        subject
      end
    end
  end

  describe '#queues' do
    subject { Configurator.new(file_name).queues }

    context 'when the config specifies queues' do
      let(:queues) { [{'...' => '...' }, { '...' => '...' }] }
      let(:config) { { 'queues' => queues } }

      it { is_expected.to eq(queues) }
    end
  end

  describe '#messages' do
    subject { Configurator.new(file_name).messages }

    context 'when the config specifies messages' do
      let(:messages) { [{'...' => '...' }, { '...' => '...' }] }
      let(:config) { { 'messages' => messages } }

      it { is_expected.to eq(messages) }
    end
  end

  describe '#rabbit_url' do
    subject { Configurator.new(file_name).rabbit_url }

    context 'when the config specifies all the components of a rabbitmq URL' do
      let(:rabbitmq) { { 'protocol' => 'amp', 'host' => 'locohost', 'username' => 'spameggs', 'password' => 'foobar', 'port' => '1234' } }
      let(:config) { { 'rabbitmq' => rabbitmq } }

      it { is_expected.to eq('amp://spameggs:foobar@locohost:1234') }
    end
  end

  describe '#routing_suffix' do
    subject { Configurator.new(file_name).routing_suffix }

    context 'when the config specifies a routing suffix' do
      let(:config) { { 'routing_suffix' => 'foobar' } }

      it { is_expected.to eq('foobar') }
    end
  end

  describe '#validate' do
    subject { Configurator.new(file_name).validate }

    context 'when the config does not specify a routing suffix' do
      let(:config) { {} }

      it 'errors out because inbound queues must have a "route_me" suffix' do
        expect { subject }.to raise_error(RuntimeError, Configurator::MISSING_ROUTING_SUFFIX)
      end
    end

    context 'when the config specifies a routing suffix' do
      let(:more_values) { { 'routing_suffix' => 'foobar' } }

      it { is_expected.to be_an_instance_of(Configurator) }

      context 'when the config specifies a message without a type' do
        let(:config) { { 'messages' => [{}] } }

        it 'errors out because messages must have types' do
          expect { subject }.to raise_error(RuntimeError, Configurator::MUST_SPECIFY_TYPE)
        end
      end

      context 'when the config specifies two messages, but the second is without a type' do
        let(:config) { { 'messages' => [{ 'type' => 'foo' }, {}] } }

        it 'errors out because messages must have types' do
          expect { subject }.to raise_error(RuntimeError, Configurator::MUST_SPECIFY_TYPE)
        end
      end

      context 'when the config specifies two messages with types' do
        let(:config) { { 'messages' => [{ 'type' => 'foo' }, { 'type' => 'bar'}] } }

        it { is_expected.to be_an_instance_of(Configurator) }
      end

      context 'when the config specifies a message with a type' do
        let(:config) { { 'messages' => [{ 'type' => 'foo' }] } }

        it { is_expected.to be_an_instance_of(Configurator) }
      end

      context 'when the config specifies both inbound and outbound queues' do
        let(:text_with_queues) { { 'queues' => [{ 'outbound' => 'foo', 'inbound' => 'bar' }] } }
        let(:config) { text_with_queues }

        it { is_expected.to be_an_instance_of(Configurator) }

        context 'and the config specifies a listener that is an outbound queue' do
          let(:config) { text_with_queues.merge('messages' => [{ 'type' => 'foo', 'listeners' => ['foo'] }]) }

          it { is_expected.to be_an_instance_of(Configurator) }
        end
      end
    end
  end
end
