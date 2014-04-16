require 'spec_helper'

describe BatchUpdate do

  describe '#apply_attributes' do

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

      describe 'derived attribute stored_collection_id' do
        it 'sets the value if it is empty' do
          obj = TuftsBase.new(title: 'Title',  displays: ['dl'])
          obj.save!
          obj.stored_collection_id.should be_nil
          obj.apply_attributes(stored_collection_id: 'new:123')
          obj.reload
          obj.stored_collection_id.should == 'new:123'
          obj.delete
        end

        it 'preserves the existing value' do
          existing_id = 'existing:123'
          obj = TuftsBase.new(title: 'Title',  displays: ['dl'], stored_collection_id: existing_id)
          obj.save!
          obj.stored_collection_id.should == existing_id
          obj.apply_attributes(stored_collection_id: 'new:123')
          obj.reload
          obj.stored_collection_id.should == existing_id
          obj.delete
        end
      end  # stored_collection_id

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

      describe 'derived attribute stored_collection_id' do
        it 'sets the value if it is empty' do
          obj = TuftsBase.new(title: 'Title',  displays: ['dl'])
          obj.save!
          obj.stored_collection_id.should be_nil
          obj.apply_attributes({stored_collection_id: 'new:123'}, nil, true)
          obj.reload
          obj.stored_collection_id.should == 'new:123'
          obj.delete
        end

        it 'overwrites existing value' do
          existing_id = 'existing:123'
          obj = TuftsBase.new(title: 'Title',  displays: ['dl'], stored_collection_id: existing_id)
          obj.save!
          obj.stored_collection_id.should == existing_id
          obj.apply_attributes({stored_collection_id: 'new:123'}, nil, true)
          obj.reload
          obj.stored_collection_id.should == 'new:123'
          obj.delete
        end
      end  # stored_collection_id

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
        result.should be_true
      end

      it 'returns false if the record failed to save' do
        @obj.should_receive(:save).and_return(false)
        result = @obj.apply_attributes(description: 'new desc')
        result.should be_false
      end

      it 'adds an entry to the audit log' do
        user = FactoryGirl.create(:user)
        @obj.apply_attributes({description: 'new desc'}, user.id)
        @obj.reload
        @obj.audit_log.who.include?(user.user_key).should be_true
      end
    end

  end  # apply_attributes method

end
