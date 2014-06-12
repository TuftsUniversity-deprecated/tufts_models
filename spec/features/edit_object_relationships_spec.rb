require 'spec_helper'

feature "Edit an object's rels-ext fields:" do

  let(:old_pid) { 'old:1' }
  let(:new_pid) { 'new:1' }

  let(:old_uri) { "info:fedora/#{old_pid}" }
  let(:new_uri) { "info:fedora/#{new_pid}" }

  let!(:pdf) {
    obj = FactoryGirl.create(:tufts_pdf)
    obj.add_relationship(:has_part, old_uri)
    obj.save!
    obj
  }

  after { pdf.delete }
  before { sign_in :admin }

  scenario 'add a new relationship' do
    visit catalog_path(pdf)
    click_link 'Edit Metadata'

    # Check for existing rels-ext field
    expect(page).to have_selector('select option[value=has_part][selected=selected]')
    expect(page).to have_selector("input[value='#{old_pid}']")

    # Add a new rels-ext field
    within('#additional_relationship_attributes_clone') do
      select 'Has Part'
      fill_in "tufts_pdf[relationship_attributes][][relationship_value]", with: new_pid
    end
    click_button 'Save'

    reloaded_pdf = TuftsPdf.find(pdf.pid)
    part_predicate = reloaded_pdf.object_relations.uri_predicate(:has_part)
    has_part = reloaded_pdf.object_relations.relationships[part_predicate]
    expect(has_part.length).to eq 2
    expect(has_part.include?(old_uri)).to be_truthy
    expect(has_part.include?(new_uri)).to be_truthy
  end

  scenario 'change the type of an existing relationship' do
    part_predicate = pdf.object_relations.uri_predicate(:has_part)
    has_part = pdf.object_relations.relationships[part_predicate]
    expect(has_part).to eq [old_uri]

    visit catalog_path(pdf)
    click_link 'Edit Metadata'

    selector = find(:xpath, '//div[@class = "record_relationship_fields"]/select[option[@selected="selected"]]')
    selector.select('Has Annotation')
    click_button 'Save'

    reloaded_pdf = TuftsPdf.find(pdf.pid)

    part_predicate = reloaded_pdf.object_relations.uri_predicate(:has_part)
    has_part = reloaded_pdf.object_relations.relationships[part_predicate]
    expect(has_part).to eq []

    ann_predicate = reloaded_pdf.object_relations.uri_predicate(:has_annotation)
    has_ann = reloaded_pdf.object_relations.relationships[ann_predicate]
    expect(has_ann).to eq [old_uri]
  end

end
