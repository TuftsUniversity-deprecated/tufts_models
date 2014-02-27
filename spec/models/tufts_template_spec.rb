require 'spec_helper'

describe TuftsTemplate do

  it 'has no required fields' do
    subject.required?(:title).should be_false
    subject.required?(:displays).should be_false
  end

  describe 'publishing' do
    it 'cannot be pushed to the production environment' do
      expect{ subject.push_to_production! }.to raise_error(UnpublishableModelError)
    end

    it 'is never published' do
      subject.published?.should be_false
    end
  end

end
