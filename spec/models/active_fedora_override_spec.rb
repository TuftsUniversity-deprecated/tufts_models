require 'spec_helper'


describe "Overrides of ActiveFedora" do
  describe "ActiveFedora::Module.classname_from_uri" do
    it "should return a uri" do
      expect(ActiveFedora::Model.classname_from_uri('info:fedora/cm:Audio')).to eq ['TuftsAudio', 'afmodel']
      expect(ActiveFedora::Model.classname_from_uri('info:fedora/cm:Audio.OralHistory')).to eq ['TuftsAudioText', 'afmodel']
      expect(ActiveFedora::Model.classname_from_uri('info:fedora/cm:Image.3DS')).to eq ['TuftsImage', 'afmodel']
      #TODO uh-oh! This mapping isn't reversable, which cm should a TuftsImage get?
      expect(ActiveFedora::Model.classname_from_uri('info:fedora/cm:Image.4DS')).to eq ['TuftsImage', 'afmodel']
      expect(ActiveFedora::Model.classname_from_uri('info:fedora/cm:Image.HTML')).to eq ['TuftsImageText', 'afmodel']
      expect(ActiveFedora::Model.classname_from_uri('info:fedora/cm:WP')).to eq ['TuftsWP', 'afmodel']
      expect(ActiveFedora::Model.classname_from_uri('info:fedora/cm:Text.FacPub')).to eq ['TuftsFacultyPublication', 'afmodel']
      expect(ActiveFedora::Model.classname_from_uri('info:fedora/cm:Text.PDF')).to eq ['TuftsPdf', 'afmodel']
      expect(ActiveFedora::Model.classname_from_uri('info:fedora/cm:Object.Generic')).to eq ['TuftsGenericObject', 'afmodel']
      expect(ActiveFedora::Model.classname_from_uri('info:fedora/cm:Text.EAD')).to eq ['TuftsEAD', 'afmodel']
      expect(ActiveFedora::Model.classname_from_uri('info:fedora/cm:Text.TEI-Fragmented')).to eq ['TuftsTeiFragmented', 'afmodel']
      expect(ActiveFedora::Model.classname_from_uri('info:fedora/cm:Text.TEI')).to eq ['TuftsTEI', 'afmodel']
      expect(ActiveFedora::Model.classname_from_uri('info:fedora/cm:Text.RCR')).to eq ['TuftsRCR', 'afmodel']
      expect(ActiveFedora::Model.classname_from_uri('info:fedora/cm:VotingRecord')).to eq ['TuftsVotingRecord', 'afmodel']
    end
  end

  describe "roundtrip object from fedora" do
    it "should be cast to the correct class" do
      obj = TuftsAudio.create!(title: "an audio", displays: ['dl'])
      expect(ActiveFedora::Base.find(obj.pid, cast:true)).to eq obj
    end
  end

end
