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

  def tufts_departments
     {
        'Africa and The New World'=>'UA005.018',
        'Biopsychology (interdisciplinary major)'=>'UA005.037',
        'Dept. of Biology'=>'UA005.010',
        'Dept. of Biomedical Engineering'=>'UA005.019',
        'Dept. of Child Development'=>'UA005.009',
        'Dept. of Civil Engineering'=>'UA005.040',
        'Dept. of Classics'=>'UA005.025',
        'Dept. of Computer Science'=>'UA005.036',
        'Dept. of Drama and Dance'=>'UA005.026',
        'Dept. of Economics'=>'UA005.003',
        'Dept. of Electrical and Computer Engineering'=>'UA005.035',
        'Dept. of English'=>'UA005.005',
        'Dept. of Geology'=>'UA005.038',
        'Dept. of History'=>'UA005.001',
        'Dept. of International Letters and Visual Studies'=>'UA005.033',
        'Dept. of Mathematics'=>'UA005.032',
        'Dept. of Mechanical Engineering'=>'UA005.028',
        'Dept. of Music'=>'UA005.034',
        'Dept. of Philosophy'=>'UA005.002',
        'Dept. of Physics'=>'UA005.022',
        'Dept. of Political Science'=>'UA005.007',
        'Dept. of Psychology'=>'UA005.006',
        'Dept. of Religion'=>'UA005.024',
        'Dept. of Romance Languages'=>'UA005.020',
        'Dept. of Sociology/Anthropology'=>'UA005.011',
        'Dept. of Chemical and Bio Engineering'=>'UA005.012',
        'Dept. of Art and Art History'=>'UA005.013',
        'Dept. of German,  Russian,  and Asian Languages and Literature'=>'UA005.014',
        'Dept. of Chemistry'=>'UA005.015',
        'Plan of Study'=>'UA005.016',
        'Program in American Studies'=>'UA005.008',
        'Program in Archaeology'=>'UA005.030',
        'Program in Asian Studies'=>'UA005.017',
        'Program in Community Health'=>'UA005.031',
        'Program in Engineering Psychology'=>'UA005.029',
        'Program in International Relations'=>'UA005.004',
        'Program in Judaic Studies'=>'UA005.023',
        'Program in Peace and Justice Studies'=>'UA005.039',
        'Program in Women''s studies'=>'UA005.027',
        '[Other]'=>'other'
    }
  end
end
