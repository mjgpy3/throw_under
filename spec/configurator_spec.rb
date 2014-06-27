require './lib/configurator.rb'

def file_under_test
  __FILE__.sub('_spec', '').sub('spec', 'lib')
end

describe Configurator do

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
    let(:file_name) { 'config.yaml' }
    subject { Configurator.new(file_name).validate }

    context 'when a config file exists in the expected directory' do
      before(:each) do
        File.open(file_name, 'w') { |file| file.write('') }
      end

      it { is_expected.to be_an_instance_of(Configurator) }
    end
  end
end
