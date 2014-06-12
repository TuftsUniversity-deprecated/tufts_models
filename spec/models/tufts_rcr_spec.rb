require 'spec_helper'

describe TuftsRCR do
  
  describe "with access rights" do
    before do
      @rcr = TuftsRCR.new(title: 'test rcr', displays: ['dl'])
      @rcr.read_groups = ['public']
      @rcr.save!
    end

    after do
      @rcr.destroy
    end

    let (:ability) {  Ability.new(nil) }

    it "should be visible to a not-signed-in user" do
      ability.can?(:read, @rcr.pid).should be_truthy
    end
  end

end
