require 'spec_helper'

describe "batches/_form_batch_template_update.html.erb" do

  before do
    @templates = [
      FactoryGirl.create(:tufts_template),
      FactoryGirl.create(:tufts_template)
    ]
    @pids = ["tufts:1", "tufts:2"]
    assign :batch, Batch.new(pids: @pids, type: 'BatchTemplateUpdate')
    render
  end

  it 'submits to batch#create' do
    rendered.should have_selector("form[method=post][action='#{batches_path}']")
  end

  it 'displays the form to apply a template' do
    expect(rendered).to have_selector("input[type=hidden][name='batch[type]'][value=BatchTemplateUpdate]")
    expect(rendered).to have_selector("select[name='batch[template_id]']")
    @pids.each do |pid|
      expect(rendered).to have_selector("input[type=hidden][name='batch[pids][]'][value='#{pid}']")
    end
    @templates.each do |t|
      rendered.should have_selector("option[value='#{t.id}']")
    end
  end

end
