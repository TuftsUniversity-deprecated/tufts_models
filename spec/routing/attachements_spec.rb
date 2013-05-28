require 'spec_helper'

describe "routes" do
  it "should have routes without periods" do
    expect(:put => "/records/changeme:4733/attachments/ARCHIVAL_WAV").to route_to(
      :action=>"update",
      :controller => "attachements",
      :record_id => 'changeme:4733',
      :id => "ARCHIVAL_WAV"
    )
  end
  it "should have routes with periods" do
    expect(:put => "/records/changeme:4733/attachments/Archival.pdf").to route_to(
      :action=>"update",
      :controller => "attachements",
      :record_id => 'changeme:4733',
      :id => "Archival.pdf"
    )
  end
end
