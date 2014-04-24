require 'spec_helper'

describe "batches/index.html.erb" do
  let(:batches) do
    [FactoryGirl.create(:batch_template_update, job_ids: [1, 2]),
      FactoryGirl.create(:batch_template_import, job_ids: nil, pids: nil)]
  end

  before do
    assign :batches, batches
    render
  end

  it "shows a list of batches" do
    batches.each do |batch|
      expect(rendered).to have_selector('.batch_id', text: batch.id)
      expect(rendered).to have_selector('.display_name', text: batch.display_name)
      expect(rendered).to have_selector('.creator', text: batch.creator.display_name)
      expect(rendered).to have_selector(".created_at", text: time_ago_in_words(batch.created_at))
      expect(rendered).to have_selector(".status", text: 'Completed')
    end
    expect(rendered).to have_selector(".item_count", text: 2)
    expect(rendered).to have_selector(".item_count", text: 0)
  end
end
