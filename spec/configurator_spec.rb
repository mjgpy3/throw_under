require './lib/configurator.rb'

def file_under_test
  __FILE__.sub('_spec', '').sub('spec', 'lib')
end

describe Configurator do
  let(:text) { 'foo:' }
  let(:file_name) { 'config.tst.yaml' }

  before(:each) do
    File.open('./config/config.tst.yaml', 'w') { |file| file.write(YAML.dump(text)) }
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

  describe '#validate' do
    subject { Configurator.new(file_name).validate }

    it { is_expected.to be_an_instance_of(Configurator) }

    context 'when the config specifies a message without a type' do
      let(:text) { { 'messages' => [{}] } }

      it 'errors out because messages must have types' do
        expect { subject }.to raise_error(RuntimeError, Configurator::MUST_SPECIFY_TYPE)
      end
    end

    context 'when the config specifies two messages, but the second is without a type' do
      let(:text) { { 'messages' => [{ 'type' => 'foo' }, {}] } }

      it 'errors out because messages must have types' do
        expect { subject }.to raise_error(RuntimeError, Configurator::MUST_SPECIFY_TYPE)
      end
    end

    context 'when the config specifies two messages with types' do
      let(:text) { { 'messages' => [{ 'type' => 'foo' }, { 'type' => 'bar'}] } }

      it { is_expected.to be_an_instance_of(Configurator) }
    end

    context 'when the config specifies a message with a type' do
      let(:text) { { 'messages' => [{ 'type' => 'foo' }] } }

      it { is_expected.to be_an_instance_of(Configurator) }
    end

    context 'when the config specifies multiple queues, missing inbound' do
      let(:text) { { 'queues' => [{ 'outbound' => 'foo', 'inbound' => 'bar' }, { 'outbound' => 'fizz' }] } }

      it 'errors out because inbound queues must be specified' do
        expect { subject }.to raise_error(RuntimeError, Configurator::MUST_SPECIFY_INBOUND)
      end
    end

    context 'when the config specifies multiple queues, missing outbound' do
      let(:text) { { 'queues' => [{ 'outbound' => 'foo', 'inbound' => 'bar' }, { 'inbound' => 'fizz' }] } }

      it 'errors out because outbound queues must be specified' do
        expect { subject }.to raise_error(RuntimeError, Configurator::MUST_SPECIFY_OUTBOUND)
      end
    end

    context 'when the config specifies both inbound and outbound queues' do
      let(:text_with_queues) { { 'queues' => [{ 'outbound' => 'foo', 'inbound' => 'bar' }] } }
      let(:text) { text_with_queues }

      it { is_expected.to be_an_instance_of(Configurator) }

      context 'and the config specifies a listener that is an outbound queue' do
        let(:text) { text_with_queues.merge('messages' => [{ 'type' => 'foo', 'listeners' => ['foo'] }]) }

        it { is_expected.to be_an_instance_of(Configurator) }
      end

      context 'and the config specifies a listener that is not an outbound queue' do
        let(:text) { text_with_queues.merge('messages' => [{ 'type' => 'foo', 'listeners' => ['not_outbound'] }]) }

        it 'errors out because all listeners must be outbound queues' do
          expect { subject }.to raise_error(RuntimeError, Configurator::LISTENERS_MUST_BE_QUEUES)
        end
      end
    end

    context 'when the config\'s yaml has an outbound queue but not an inbound' do
      let(:text) { { 'queues' => [{ 'outbound' => 'foo' }] } }

      it 'errors out because inbound queues must be specified' do
        expect { subject }.to raise_error(RuntimeError, Configurator::MUST_SPECIFY_INBOUND)
      end
    end

    context 'when the config\'s yaml has an inbound queue but not an outbound' do
      let(:text) { { 'queues' => [{ 'inbound' => 'foo' }] } }

      it 'errors out because outbound queues must be specified' do
        expect { subject }.to raise_error(RuntimeError, Configurator::MUST_SPECIFY_OUTBOUND)
      end
    end
  end
end
