require 'spec_helper'

describe 'catalog/_show_tools.html.erb' do
  before do
    view.stub(:can?) { true }
  end

  it 'displays a link to the attached files' do
    doc = SolrDocument.new(id: 'pid:1')
    assign :document, doc
    render
    assert_select "li[class=?]", nil do
      assert_select "a[href=?]", record_attachments_path(doc), { text: 'Manage Datastreams' }
    end
  end

  it 'disables link to the attached files for a template' do
    doc = SolrDocument.new(id: 'pid:1', active_fedora_model_ssi: 'TuftsTemplate')
    assign :document, doc
    render
    assert_select "li[class=?]", 'disabled' do
      assert_select "a[href=?]", '#', { text: 'Manage Datastreams' }
    end
  end

end
