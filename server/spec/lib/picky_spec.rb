require 'spec_helper'

describe Picky do

  it 'sets the right internal encoding' do
    Encoding.default_external.should == Encoding::UTF_8
  end
  # TODO Set default external encoding.
  #
  # it 'sets the right external encoding' do
  #   Encoding.default_internal.should == Encoding::UTF_8
  # end
  
end