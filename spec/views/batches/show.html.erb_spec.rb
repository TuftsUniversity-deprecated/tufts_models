require 'spec_helper'

describe "batches/show.html.erb" do
  describe 'apply_template' do
    subject { FactoryGirl.create(:batch_template_update, pids: docs.map(&:id)) }
    let(:docs) { [FactoryGirl.create(:tufts_pdf)] }
    let(:jobs) { [] }

    before do
      assign :batch, subject
      assign :records, docs
      assign :jobs, jobs
    end

    it "shows general information" do
      pending "reviews working on records"
      render
      expect(rendered).to have_selector(".batch_id", text: subject.id)
      expect(rendered).to have_selector(".record_count", text: docs.count)
      expect(rendered).to have_selector(".creator", text: subject.creator.display_name)
      expect(rendered).to have_selector(".created_at", text: subject.created_at)
      expect(rendered).to have_selector(".status", text: 'Complete')
      expect(rendered).to have_selector(".review_status", text: 'Complete')
    end

    it "shows record pids" do
      pending "the addition of records to the Batch#show page"
      expect(rendered).to have_selector(".record_pid", text: docs.first.pid)
    end

    it "shows record titles" do
      pending "the addition of records to the Batch#show page"
      expect(rendered).to have_selector(".record_title", text: docs.first.title)
    end

    it "shows record status" do
      pending "the addition of records to the Batch#show page"
      expect(rendered).to have_selector(".record_status", text: "FIXME")
    end

    it "shows review status of each record" do
      pending "the addition of records to the Batch#show page"
      expect(rendered).to have_selector(".record_reviewed_status", text: "Reviewed")
    end

    context "with some records reviewed" do
      let(:docs) do
        d1 = FactoryGirl.create(:tufts_audio)
        d2 = FactoryGirl.create(:tufts_pdf)
        # d1.reviewed!
        [d1, d2]
      end

      it "shows aa complete status when all docs have been reviewed" do
        pending "reviews working on records"
        render
        expect(rendered).to have_selector(".status", text: subject.id)
      end
    end

    context "with all records reviewed" do
      let(:docs) do
        doc = FactoryGirl.create(:tufts_pdf)
        # doc.reviewed!
        [doc]
      end

      it "shows an incomplete status when some docs haven't been reviewed" do
        pending "reviews working on records"
        render
        expect(rendered).to have_selector(".status", text: subject.id)
      end
    end
  end
end
