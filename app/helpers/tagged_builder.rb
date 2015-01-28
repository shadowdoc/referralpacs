class TaggedBuilder < ActionView::Helpers::FormBuilder
  # Generate something like:
  # <p>
  # <label for="product_description">Description</label><br/>
  # <%= form.text_area 'description' %>
  # </p>
  def self.create_tagged_field(method_name)
    define_method(method_name) do |label, *args|
      @template.content_tag("p" ,
        @template.content_tag("label", 
                              label.to_s.humanize,
                              :for => "#{@object_name}_#{label}" ) + @template.tag("br") + super(label, *args))
    end
  end
  
  field_helpers.each do |name|
    create_tagged_field(name)
  end 
  
  [:date_select, :collection_select].each do |name|
    create_tagged_field(name)
  end
  
end