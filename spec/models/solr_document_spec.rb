require 'spec_helper'

describe SolrDocument do
  describe "#preview_path" do
    before { subject['id'] = 'tufts:7'}
    describe "when displays is empty" do
      its(:preview_path) {should == 'http://dev-dl.lib.tufts.edu/catalog/tufts:7'}
    end
    describe "when displays is 'dl'" do
      before { subject['displays_ssi'] = 'dl' }
      its(:preview_path) {should == 'http://dev-dl.lib.tufts.edu/catalog/tufts:7'}
    end
    describe "when displays is something else" do
      before { subject['displays_ssi'] = 'tisch'}
      its(:preview_path) {should == 'http://localhost:8983/fedora/objects/tufts:7'}
    end
  end
end
