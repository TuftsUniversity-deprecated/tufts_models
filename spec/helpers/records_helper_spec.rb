require 'spec_helper'

describe RecordsHelper do
  it "should have object_type_options" do
    helper.object_type_options.should == {'Audio' => 'TuftsAudio', 'PDF' => 'TuftsPdf'}
  end
end
