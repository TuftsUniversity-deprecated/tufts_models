require 'spec_helper'

describe "routes" do
  it "should have routes without periods" do
    expect(:put => "/records/tufts:001.102.201/attachments/ARCHIVAL_WAV").to route_to(
      :action=>"update",
      :controller => "attachments",
      :record_id => 'tufts:001.102.201',
      :id => "ARCHIVAL_WAV"
    )
  end
  it "should have routes with periods" do
    expect(:put => "/records/tufts:001.102.201/attachments/Archival.pdf").to route_to(
      :action=>"update",
      :controller => "attachments",
      :record_id => 'tufts:001.102.201',
      :id => "Archival.pdf"
    )
  end
end
