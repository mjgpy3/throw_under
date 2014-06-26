require './lib/configurator.rb'

describe Configurator do
  describe '#initialize' do
    subject { Configurator.new('some_file_name') }

    it { is_expected.to be_an_instance_of(Configurator) }
  end
end
