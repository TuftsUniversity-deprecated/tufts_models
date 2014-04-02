require 'spec_helper'

describe "batches/new.html.erb" do

  context 'Batch type: BatchTemplateUpdate' do
    before do
      templates = [
        FactoryGirl.create(:tufts_template),
        FactoryGirl.create(:tufts_template)
      ]
      pids = ["tufts:1", "tufts:2"]
      assign :batch, Batch.new(pids: pids, type: 'BatchTemplateUpdate')
      render
    end

    it 'renders the form for BatchTemplateUpdate' do
      expect(view.rendered_views.rendered_views).to include('batches/form_batch_template_update')
    end
  end

end
