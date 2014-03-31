require 'spec_helper'

describe "batches/show.html.erb" do
  describe 'apply_template' do
    subject { FactoryGirl.create(:batch_template_update,
                                 pids: records.map(&:id),
                                 job_ids: jobs.map(&:uuid)) }
    let(:records) { [FactoryGirl.create(:tufts_pdf)] }
    let(:records_by_pid) { records.reduce({}){|acc,r| acc.merge(r.pid => r)} }
    let(:jobs) do
      records.zip(0.upto(records.length)).map do |r, uuid|
        double('uuid' => uuid,
             'status' => 'queued',
             'options' => {'record_id' => r.id})
      end
    end

    before do
      allow(Resque::Plugins::Status::Hash).to receive(:get) do |uuid|
        jobs.find{|j| j.uuid == uuid}
      end
      assign :batch, subject
      assign :records_by_pid, records_by_pid
    end

    it "shows batch information" do
      render
      expect(rendered).to have_selector(".type", text: subject.display_name)
      expect(rendered).to have_selector(".batch_id", text: subject.id)
      expect(rendered).to have_selector(".record_count", text: records.count)
      expect(rendered).to have_selector(".creator", text: subject.creator.display_name)
      expect(rendered).to have_selector(".created_at", text: subject.created_at)
      expect(rendered).to have_selector(".status", text: 'Queued')
    end

    it "shows record pids" do
      render
      expect(rendered).to have_selector(".record_pid", text: records.first.pid)
    end

    it "shows record titles" do
      render
      expect(rendered).to have_selector(".record_title", text: records.first.title)
    end

    it "shows record status" do
      render
      expect(rendered).to have_selector(".record_status", text: "Queued")
    end

    context "with some records reviewed" do
      let(:records) do
        d1 = FactoryGirl.create(:tufts_audio)
        d2 = FactoryGirl.create(:tufts_pdf)
        d1.reviewed
        [d1, d2]
      end

      it "shows a complete reviewed status" do
        render
        expect(rendered).to have_selector(".review_status", text: "Incomplete")
      end

      it "shows review status of each record" do
        render
        expect(rendered).to have_selector(".record_reviewed_status input[type=checkbox][disabled=disabled][checked=checked]")
        expect(rendered).to have_selector(".record_reviewed_status input[type=checkbox][disabled=disabled]:not([checked=checked])")
      end
    end

    context "with all records reviewed" do
      let(:records) do
        doc = FactoryGirl.create(:tufts_pdf)
        doc.reviewed
        [doc]
      end

      it "shows an incomplete reviewed status" do
        render
        expect(rendered).to have_selector(".review_status", text: "Complete")
      end
    end

    context "with nil statuses on a recent batch" do
      subject { FactoryGirl.create(:batch_template_update,
                                   pids: records.map(&:id),
                                   job_ids: ['missing']) }

      it 'says the batch status is not availble' do
        render
        expect(rendered).to have_selector(".batch_info .status", text: "Status not available")
      end

      it 'says statuses are not availble' do
        render
        expect(rendered).to have_selector(".record_status", text: "Status not available")
      end
    end

    context "with nil statuses on an old batch" do
      subject { FactoryGirl.create(:batch_template_update,
                                   pids: records.map(&:id),
                                   job_ids: ['missing'],
                                   created_at: Resque::Plugins::Status::Hash.expire_in.ago) }

      it 'says the batch status is not availble' do
        render
        expect(rendered).to have_selector(".batch_info .status", text: "Status not available")
      end

      it 'says the status is expired' do
        render
        expect(rendered).to have_selector(".record_status", text: "Status expired")
      end
    end

    describe 'batch actions: ' do
      context 'a batch with status "completed"' do
        before do
          allow_any_instance_of(BatchTemplateUpdate).to receive(:status) { 'completed' }
          render
        end

        it 'displays the form to publish the batch' do
          expect(rendered).to have_selector("form[method=post][action='#{batches_path}']")
          expect(rendered).to have_selector("input[type=hidden][name='batch[pids][]'][value='#{subject.pids.first}']")
          expect(rendered).to have_selector("button[type=submit][name='batch[type]'][value=BatchPublish]")
        end
      end

      context 'a batch status that is anything but "completed"' do
        before { render }

        it 'disables the button to publish the batch' do
          expect(subject.status).to eq 'queued'
          expect(rendered).to have_selector("button[type=submit][name='batch[type]'][value=BatchPublish][disabled=disabled]")
        end
      end
    end
  end
end
