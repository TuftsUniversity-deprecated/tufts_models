class DepositType < ActiveRecord::Base
  attr_accessible :display_name, :deposit_view, :deposit_agreement

  validates :display_name, presence: true, uniqueness: true
  validates :deposit_view, presence: true
  validates_each(:deposit_view) {|record, attr, value| record.errors.add(attr, 'must name a valid partial in app/views/self_deposits/metadata') unless valid_desposit_views.include? value}

  def self.valid_desposit_views
    return Dir.glob('app/views/self_deposits/metadata/_*.html.erb').collect{|f| File.basename(f,".html.erb")[1..-1]}
  end

end
