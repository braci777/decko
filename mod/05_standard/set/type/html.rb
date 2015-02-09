
view :editor do |args|
  form.text_area :content, :rows=>5, :class=>'card-content'
end

view :closed_content do |args|
  ''
end

def clean_html?
  false
end

def diff_args
 {:format=>:raw}
end

format do
  def chunk_list
    :references
  end
end