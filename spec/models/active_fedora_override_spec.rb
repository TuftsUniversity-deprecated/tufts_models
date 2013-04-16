require 'spec_helper'


describe "Overrides of ActiveFedora" do
  describe "ActiveFedora::Module.classname_from_uri" do
    it "should return a uri" do
      ActiveFedora::Model.classname_from_uri('info:fedora/cm:Audio').should == ['TuftsAudio', 'afmodel']
      ActiveFedora::Model.classname_from_uri('info:fedora/cm:Audio.OralHistory').should == ['TuftsAudioText', 'afmodel']
      ActiveFedora::Model.classname_from_uri('info:fedora/cm:Image.3DS').should == ['TuftsImage', 'afmodel']
      #TODO uh-oh! This mapping isn't reversable, which cm should a TuftsImage get?
      ActiveFedora::Model.classname_from_uri('info:fedora/cm:Image.4DS').should == ['TuftsImage', 'afmodel']
      ActiveFedora::Model.classname_from_uri('info:fedora/cm:Image.HTML').should == ['TuftsImageText', 'afmodel']
      ActiveFedora::Model.classname_from_uri('info:fedora/cm:WP').should == ['TuftsWP', 'afmodel']
      ActiveFedora::Model.classname_from_uri('info:fedora/cm:Text.FacPub').should == ['TuftsFacultyPublication', 'afmodel']
      ActiveFedora::Model.classname_from_uri('info:fedora/cm:Text.PDF').should == ['TuftsPdf', 'afmodel']
      ActiveFedora::Model.classname_from_uri('info:fedora/cm:Object.Generic').should == ['TuftsGenericObject', 'afmodel']
      ActiveFedora::Model.classname_from_uri('info:fedora/cm:Text.EAD').should == ['TuftsEAD', 'afmodel']
      ActiveFedora::Model.classname_from_uri('info:fedora/cm:Text.TEI-Fragmented').should == ['TuftsTeiFragmented', 'afmodel']
      ActiveFedora::Model.classname_from_uri('info:fedora/cm:Text.TEI').should == ['TuftsTEI', 'afmodel']
      ActiveFedora::Model.classname_from_uri('info:fedora/cm:Text.RCR').should == ['TuftsRCR', 'afmodel']
      ActiveFedora::Model.classname_from_uri('info:fedora/cm:VotingRecord').should == ['TuftsVotingRecord', 'afmodel']
    end
  end

  describe "roundtrip object from fedora" do
    it "should be cast to the correct class" do
      obj = TuftsAudio.create!
      ActiveFedora::Base.find(obj.pid, cast:true).should == obj
    end
  end

end
