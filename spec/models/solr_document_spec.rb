require 'spec_helper'

describe SolrDocument do
  before { subject['id'] = 'tufts:7'}

  describe "#preview_fedora_path" do
    describe "should always have link to fedora object" do
      before { subject['displays_ssi'] = nil }
      its(:preview_fedora_path) {should == 'http://localhost:8983/fedora/objects/tufts:7'}
      before { subject['displays_ssi'] = 'dl' }
      its(:preview_fedora_path) {should == 'http://localhost:8983/fedora/objects/tufts:7'}
      before { subject['displays_ssi'] = 'tufts' }
      its(:preview_fedora_path) {should == 'http://localhost:8983/fedora/objects/tufts:7'}
    end
  end
  
  describe "#preview_dl_path" do
    describe "when displays is 'dl'" do
      before { subject['displays_ssi'] = 'dl' }
      its(:preview_dl_path) {should == 'http://dev-dl.lib.tufts.edu/catalog/tufts:7'}
    end
    describe "when displays is not set" do
      before { subject['displays_ssi'] = nil }
      its(:preview_dl_path) {should == 'http://dev-dl.lib.tufts.edu/catalog/tufts:7'}
      before { subject['displays_ssi'] = ''}
      its(:preview_dl_path) {should == 'http://dev-dl.lib.tufts.edu/catalog/tufts:7'}
    end
    describe "when displays is something else" do
      before { subject['displays_ssi'] = 'tisch'}
      its(:preview_dl_path) {should == nil}
    end
  end

end
