require 'spec_helper'

describe 'catalog/_show_tools.html.erb' do
  before do
    view.stub(:can?) { true }
  end

  it 'displays a link to the attached files' do
    doc = SolrDocument.new(id: 'pid:1')
    assign :document, doc
    render
    expect(rendered).to have_link('Manage Datastreams', href: record_attachments_path(doc))
  end

  it 'disables link to the attached files for a template' do
    doc = SolrDocument.new(id: 'pid:1', active_fedora_model_ssi: 'TuftsTemplate')
    assign :document, doc
    render
    expect(rendered).to have_link('Manage Datastreams', href: '#')
  end

  it 'displays a link to mark the object as reviewed' do
    doc = SolrDocument.new(id: 'pid:1')
    doc.stub(:reviewable?) { true }
    assign :document, doc
    render
    expect(rendered).to have_link('Mark as Reviewed', href: review_record_path(doc))
  end

  it 'disables the review link if object is not reviewable' do
    doc = SolrDocument.new(id: 'pid:1')
    doc.stub(:reviewable?) { false }
    assign :document, doc
    render
    expect(rendered).to have_link('Mark as Reviewed', href: '#')
  end

end
