require 'spec_helper'
describe FedoraObjectCopyService do

  let(:service) { described_class.new(TuftsImage, from: 'draft:5', to: 'tufts:5') }

  describe "transmutate_export" do
    subject { service.send(:transmutate_export, xml) }

    it "changes the pid and removes invalid checksums" do
      expect(subject).not_to match 'REMOVE-THIS'
      expect(subject).not_to match 'ExceptionReadingStream'
      expect(subject).to match '40fb74bc5a85dd1339741af571ef6f0e'
      expect(subject).not_to match 'draft:5'
      expect(subject).to match 'tufts:5'
    end
  end

  let(:xml) {
    <<-EOF
<?xml version="1.0" encoding="UTF-8"?>
<foxml:digitalObject xmlns:foxml="info:fedora/fedora-system:def/foxml#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" VERSION="1.1" PID="draft:5" xsi:schemaLocation="info:fedora/fedora-system:def/foxml# http://www.fedora.info/definitions/1/0/foxml1-1.xsd">
<foxml:objectProperties>
<foxml:property NAME="info:fedora/fedora-system:def/model#state" VALUE="Active"/>
<foxml:property NAME="info:fedora/fedora-system:def/model#label" VALUE=""/>
<foxml:property NAME="info:fedora/fedora-system:def/model#ownerId" VALUE="fedoraAdmin"/>
<foxml:property NAME="info:fedora/fedora-system:def/model#createdDate" VALUE="2015-04-27T18:15:38.531Z"/>
<foxml:property NAME="info:fedora/fedora-system:def/view#lastModifiedDate" VALUE="2015-04-27T18:51:17.560Z"/>
</foxml:objectProperties>
<foxml:datastream ID="AUDIT" STATE="A" CONTROL_GROUP="X" VERSIONABLE="false">
<foxml:datastreamVersion ID="AUDIT.0" LABEL="Audit Trail for this object" CREATED="2015-04-27T18:15:38.531Z" MIMETYPE="text/xml" FORMAT_URI="info:fedora/fedora-system:format/xml.fedora.audit">
<foxml:xmlContent>
</foxml:xmlContent>
</foxml:datastreamVersion>
</foxml:datastream>
<foxml:datastream ID="DC" STATE="A" CONTROL_GROUP="X" VERSIONABLE="true">
<foxml:datastreamVersion ID="DC1.0" LABEL="Dublin Core Record for this object" CREATED="2015-04-27T18:15:38.531Z" MIMETYPE="text/xml" FORMAT_URI="http://www.openarchives.org/OAI/2.0/oai_dc/" SIZE="336">

<foxml:contentDigest TYPE="MD5" DIGEST="REMOVE-THIS"/>
<foxml:xmlContent>
<oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
  <dc:identifier>draft:5</dc:identifier>
</oai_dc:dc>
</foxml:xmlContent>
</foxml:datastreamVersion>
</foxml:datastream>
<foxml:datastream ID="RELS-EXT" STATE="A" CONTROL_GROUP="X" VERSIONABLE="true">
<foxml:datastreamVersion ID="RELS-EXT.1" LABEL="Fedora Object-to-Object Relationship Metadata" CREATED="2015-04-27T18:21:32.335Z" MIMETYPE="application/rdf+xml" SIZE="364">
<foxml:contentDigest TYPE="MD5" DIGEST="REMOVE-THIS"/>
<foxml:xmlContent>
<rdf:RDF xmlns:ns0="info:fedora/fedora-system:def/model#" xmlns:ns1="http://www.openarchives.org/OAI/2.0/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
  <rdf:Description rdf:about="info:fedora/draft:5">
    <ns1:itemID>oai:draft:5</ns1:itemID>
    <ns0:hasModel rdf:resource="info:fedora/cm:Image.4DS"/>
  </rdf:Description>
</rdf:RDF>
</foxml:xmlContent>
</foxml:datastreamVersion>
</foxml:datastream>
<foxml:datastream ID="DCA-ADMIN" STATE="A" CONTROL_GROUP="M" VERSIONABLE="true">
<foxml:datastreamVersion ID="DCA-ADMIN.0" LABEL="" CREATED="2015-04-27T18:15:39.763Z" MIMETYPE="text/xml" SIZE="162">
<foxml:contentDigest TYPE="MD5" DIGEST="7543808218cad77db2388f6f3690e097"/>
<foxml:binaryContent>
              PGFkbWluIHhtbG5zOmxvY2FsPSJodHRwOi8vbmlscy5saWIudHVmdHMuZWR1L2RjYWFkbWluLyIgeG1s
              bnM6YWM9Imh0dHA6Ly9wdXJsLm9yZy9kYy9kY21pdHlwZS8iPgogIDxsb2NhbDplZGl0ZWRBdD4yMDE1
              LTA0LTI3VDE4OjE1OjM4WjwvbG9jYWw6ZWRpdGVkQXQ+CjwvYWRtaW4+
</foxml:binaryContent>
</foxml:datastreamVersion>
</foxml:datastream>
<foxml:datastream ID="Archival.tif" STATE="A" CONTROL_GROUP="E" VERSIONABLE="true">
<foxml:datastreamVersion ID="Archival.tif.0" LABEL="File Datastream" CREATED="2015-04-27T18:16:06.171Z" MIMETYPE="image/tiff">
<foxml:contentDigest TYPE="MD5" DIGEST="ExceptionReadingStream"/>

<foxml:contentLocation TYPE="URL" REF="http://bucket01.lib.tufts.edu/data01/tufts/sas/archival_tif/5.archival.tif"/>
</foxml:datastreamVersion>
</foxml:datastream>
<foxml:datastream ID="rightsMetadata" STATE="A" CONTROL_GROUP="M" VERSIONABLE="true">
<foxml:datastreamVersion ID="rightsMetadata.0" LABEL="" CREATED="2015-04-27T18:21:32.488Z" MIMETYPE="text/xml" SIZE="561">
<foxml:contentDigest TYPE="MD5" DIGEST="f181d306f39d380592fb338c4292ab33"/>
<foxml:binaryContent>
              PHJpZ2h0c01ldGFkYXRhIHhtbG5zPSJodHRwOi8vaHlkcmEtY29sbGFiLnN0YW5mb3JkLmVkdS9zY2hl
              bWFzL3JpZ2h0c01ldGFkYXRhL3YxIiB2ZXJzaW9uPSIwLjEiPgogIDxjb3B5cmlnaHQ+CiAgICA8aHVt
              YW4gdHlwZT0idGl0bGUiLz4KICAgIDxodW1hbiB0eXBlPSJkZXNjcmlwdGlvbiIvPgogICAgPG1hY2hp
              bmUgdHlwZT0idXJpIi8+CiAgPC9jb3B5cmlnaHQ+CiAgPGFjY2VzcyB0eXBlPSJkaXNjb3ZlciI+CiAg
              ICA8aHVtYW4vPgogICAgPG1hY2hpbmUvPgogIDwvYWNjZXNzPgogIDxhY2Nlc3MgdHlwZT0icmVhZCI+
              CiAgICA8aHVtYW4vPgogICAgPG1hY2hpbmUvPgogIDwvYWNjZXNzPgogIDxhY2Nlc3MgdHlwZT0iZWRp
              dCI+CiAgICA8aHVtYW4vPgogICAgPG1hY2hpbmU+CiAgICAgIDxwZXJzb24+anVzdGluQGN1cmF0aW9u
              ZXhwZXJ0cy5jb208L3BlcnNvbj4KICAgIDwvbWFjaGluZT4KICA8L2FjY2Vzcz4KICA8ZW1iYXJnbz4K
              ICAgIDxtYWNoaW5lLz4KICA8L2VtYmFyZ28+CiAgPGxlYXNlPgogICAgPG1hY2hpbmUvPgogIDwvbGVh
              c2U+CjwvcmlnaHRzTWV0YWRhdGE+
</foxml:binaryContent>
</foxml:datastreamVersion>
</foxml:datastream>
<foxml:datastream ID="DCA-META" STATE="A" CONTROL_GROUP="M" VERSIONABLE="true">
<foxml:datastreamVersion ID="DCA-META.0" LABEL="" CREATED="2015-04-27T18:21:32.562Z" MIMETYPE="text/xml" SIZE="253">
<foxml:contentDigest TYPE="MD5" DIGEST="40fb74bc5a85dd1339741af571ef6f0e"/>
<foxml:binaryContent>
              PGRjIHhtbG5zOmRjPSJodHRwOi8vcHVybC5vcmcvZGMvZWxlbWVudHMvMS4xLyIgeG1sbnM6ZGNhZGVz
              Yz0iaHR0cDovL25pbHMubGliLnR1ZnRzLmVkdS9kY2FkZXNjLyIgeG1sbnM6ZGNhdGVjaD0iaHR0cDov
              L25pbHMubGliLnR1ZnRzLmVkdS9kY2F0ZWNoLyIgeG1sbnM6eGxpbms9Imh0dHA6Ly93d3cudzMub3Jn
              LzE5OTkveGxpbmsiIHZlcnNpb249IjAuMSI+CiAgPGRjOnRpdGxlPkEgZHJhZnQgbnVtYmVyIDU8L2Rj
              OnRpdGxlPgo8L2RjPg==
</foxml:binaryContent>
</foxml:datastreamVersion>
</foxml:datastream>
</foxml:digitalObject>
EOF
  }
end
