require 'spec_helper'

describe TuftsImageText do
  
  describe "with access rights" do
    before do
      @image_text = TuftsImageText.new
      @image_text.read_groups = ['public']
      @image_text.save!
    end

    after do
      @image_text.destroy
    end

    let (:ability) {  Ability.new(nil) }

    it "should be visible to a not-signed-in user" do
      ability.can?(:read, @image_text.pid).should be_true
    end
  end

end
