module BatchesHelper
  def make_dl(title, value, css_class)
    content_tag(:dl, class: "dl-horizontal " + css_class) do
      content_tag(:dt) { title } + 
      content_tag(:dd) { value.to_s }
    end
  end
end
