module ContributeHelper

  # Use this helper file to build constrained choice lists for self-deposit metadata input forms.
  # Follow the patterns for fletcher_degrees and tufts_departments below.
  # In general, provide a has which contains the display label you would like displayed in the selection
  # box as the hash key and the value you would like to have returned in the input field as the hash value.
  # Hashes used for selections will display in the order listed here unless further sorting is applied in the view.

  def fletcher_degrees
     {
        :LLM =>'FL001.001',
        :MALD=>'FL001.002',
        :MIB=>'FL001.003'
    }
  end

  def tufts_department_labels
    Qa::Authorities::Local.sub_authority('departments').terms.map do |element|
      element[:term]
    end
  end
end
