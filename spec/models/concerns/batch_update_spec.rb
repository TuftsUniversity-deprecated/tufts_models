require 'spec_helper'

describe BatchUpdate do

  describe '#apply_attributes' do
    let(:old_pid) { "old:123" }
    let(:old_uri) { "info:fedora/#{old_pid}" }

    let(:new_pid) { "new:123" }
    let(:new_uri) { "info:fedora/#{new_pid}" }

    describe 'when overwrite = false,' do

      describe 'for single-value attributes' do
        before do
          @old_attrs = { title: 'old title', displays: ['dl'] }
          @obj = TuftsBase.new(@old_attrs)
          @obj.save!
        end

        after { @obj.delete }

        it 'preserves existing values and adds new values' do
          expect(@obj.createdby).to be_nil   # no old value
          new_attrs = { title: 'new title',
                        createdby: 'new createdby' }
          @obj.apply_attributes(new_attrs)
          @obj.reload

          expect(@obj.createdby).to eq new_attrs[:createdby]
          expect(@obj.creatordept).to be_nil
          expect(@obj.title).to eq @old_attrs[:title]
        end
      end  # single-value attributes

      describe 'for multi-value attributes' do
        before do
          @old_attrs = { title: 'Title',  displays: ['dl'], description: ['old desc'] }
          @obj = TuftsBase.new(@old_attrs)
          @obj.save!
        end

        after { @obj.delete }

        it 'adds new values to existing values' do
          expect(@obj.toc).to eq []     # no old value
          expect(@obj.genre).to eq []   # no old value
          new_attrs = { description: ['new desc'], genre: 'new genre' }
          @obj.apply_attributes(new_attrs)
          @obj.reload

          expect(@obj.toc).to eq []
          expect(@obj.genre).to eq Array(new_attrs[:genre])
          expect(@obj.displays).to eq @old_attrs[:displays]
          expect(@obj.description).to eq @old_attrs[:description] + new_attrs[:description]
        end

        it 'doesnt duplicate multi-value entries' do
          @obj.apply_attributes(description: @old_attrs[:description])
          @obj.reload
          expect(@obj.description).to eq @old_attrs[:description]
        end
      end  # multi-value attributes

      describe 'for rels-ext attributes' do
        let(:pdf) { FactoryGirl.build(:tufts_pdf) }
        after { pdf.delete }

        let(:new_attrs) { { 'relationship_attributes' => [
            { "relationship_name" => :is_part_of,
              "relationship_value" => new_pid },
            { "relationship_name" => :is_member_of_collection,
              "relationship_value" => new_pid } ]} }

        before do
          pdf.add_relationship(:is_part_of, old_uri)
          pdf.add_relationship(:is_subset_of, old_uri)
          pdf.save!
        end

        it 'adds new values and keeps existing values' do
          pdf.apply_attributes(new_attrs, nil, false)

          is_subset_of = pdf.ids_for_outbound(:is_subset_of)
          is_part_of = pdf.ids_for_outbound(:is_part_of)
          is_member_of = pdf.ids_for_outbound(:is_member_of_collection)

          expect(is_subset_of).to eq [old_pid]
          expect(is_part_of).to   eq [old_pid, new_pid]
          expect(is_member_of).to eq [new_pid]
        end
      end  # rels-ext attributes
    end  # when overwrite = false


    describe 'when overwrite = true,' do
      before { @user = FactoryGirl.create(:user) }
      after  { @user.delete }

      describe 'for single-value attributes' do
        before do
          @old_attrs = { title: 'old title', displays: ['dl'] }
          @obj = TuftsBase.new(@old_attrs)
          @obj.save!
        end

        after { @obj.delete }

        it 'overwrites existing values' do
          expect(@obj.createdby).to be_nil   # no old value
          new_attrs = { title: 'new title',
                        createdby: 'new createdby' }
          @obj.apply_attributes(new_attrs, @user.id, true)
          @obj.reload

          expect(@obj.title).to eq new_attrs[:title]
          expect(@obj.createdby).to eq new_attrs[:createdby]
          expect(@obj.creatordept).to be_nil
        end
      end  # single-value attributes

      describe 'for multi-value attributes' do
        before do
          @old_attrs = { title: 'Title',  displays: ['dl'], description: ['old desc'] }
          @obj = TuftsBase.new(@old_attrs)
          @obj.save!
        end

        after { @obj.delete }

        it 'adds new values and overwrites existing values' do
          expect(@obj.toc).to eq []     # no old value
          expect(@obj.genre).to eq []   # no old value
          new_attrs = { description: ['new desc'], genre: 'new genre' }
          @obj.apply_attributes(new_attrs, @user.id, true)
          @obj.reload

          expect(@obj.toc).to eq []
          expect(@obj.genre).to eq Array(new_attrs[:genre])
          expect(@obj.displays).to eq @old_attrs[:displays]
          expect(@obj.description).to eq new_attrs[:description]
        end
      end  # multi-value attributes

      describe 'for rels-ext attributes' do
        let(:pdf) { FactoryGirl.build(:tufts_pdf) }
        after { pdf.delete }

        before do
          pdf.add_relationship(:is_part_of, old_uri)
          pdf.add_relationship(:has_subset, old_uri)
          pdf.save!
        end

        it 'adds new values and overwrites existing values' do
          new_attrs = { 'relationship_attributes' => [
            { "relationship_name" => :is_part_of,
              "relationship_value" => new_pid },
            { "relationship_name" => :is_member_of_collection,
              "relationship_value" => new_pid } ]}

          pdf.apply_attributes(new_attrs, @user.id, true)

          expect(pdf.ids_for_outbound(:is_part_of)).to eq [new_pid]
          expect(pdf.ids_for_outbound(:is_member_of_collection)).to eq [new_pid]
          expect(pdf.ids_for_outbound(:has_subset)).to eq [old_pid]
        end

        it 'gracefully handles strings or symbols' do
          string_name = 'is_part_of'
          symbol_name = :has_subset
          new_attrs = { 'relationship_attributes' => [
            { "relationship_name" => string_name,
              "relationship_value" => new_pid },
            { "relationship_name" => symbol_name,
              "relationship_value" => new_pid } ]}

          pdf.apply_attributes(new_attrs, @user.id, true)
          expect(pdf.ids_for_outbound(:has_subset)).to eq [new_pid]
          expect(pdf.ids_for_outbound(:is_part_of)).to eq [new_pid]
        end
      end  # rels-ext attributes
    end  # when overwrite = true


    describe 'general case (whether overwrite is true or false)' do
      before do
        @obj = TuftsBase.new(title: 'old title', displays: ['dl'],
                             description: ['old desc 1', 'old desc 2'])
        @obj.save!
      end

      after { @obj.delete }

      it 'returns true if the record successfully saved' do
        result = @obj.apply_attributes(description: 'new desc')
        expect(result).to be_truthy
      end

      it 'returns false if the record failed to save' do
        expect(@obj).to receive(:save).and_return(false)
        result = @obj.apply_attributes(description: 'new desc')
        expect(result).to be_falsey
      end

      it 'adds an entry to the audit log' do
        user = FactoryGirl.create(:user)
        @obj.apply_attributes({description: 'new desc'}, user.id)
        @obj.reload
        expect(@obj.audit_log.who.include?(user.user_key)).to be_truthy
      end
    end

  end  # apply_attributes method

end
