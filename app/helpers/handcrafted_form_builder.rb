class HandcraftedFormBuilder < ActionView::Helpers::FormBuilder 
  
  ["file_field", "password_field", "text_field", "text_area", "check_box"].each do |name|
    define_method("#{name}_with_div") do |label, *args|
      options = args.first || {}
      @template.content_tag(:div, :class => "row #{name}") do
        build_label(label, name, options[:label]) + send("#{name}_without_div", label, build_example(:example, options)) + build_hint(options[:hint])
      end
    end
    alias_method_chain name.to_sym, :div
  end
  
  {"first_last" => ["first", "last"], "phone_number" => ["area_code", "prefix", "line_number"]}.each do |name, fields|
    define_method(name) do |*args|
      options = args.last.class == Hash ? args.pop : {}
      field_tags = []
      fields.each_index do |i|
        field_tags << @template.content_tag(:div, :class => fields[i]) do
          build_label(args[i], name, options["#{fields[i]}_label"]) +  text_field_without_div(args[i], build_example("#{fields[i]}_example", options)) + build_hint(options[:hint])
        end
      end
      @template.content_tag(:div, :class => "row #{name} clearfix") do
        field_tags.join
      end
    end
  end
  
  def select_with_div(name, choices, *args)
    options = args.first || {}
    @template.content_tag(:div, :class => "row select") do
      options[:style] ? (style_start="<span style='#{options[:style]}'>"; style_end="</span>") : (style_start=""; style_end="")
      build_label(name, "select", options[:label]) + style_start + select_without_div(name, choices, build_example(:example, options)) +style_end + build_hint(options[:hint])
    end
  end
  alias_method_chain :select, :div
  
  def time_zone_select_with_div(name, choices, *args)
    options = args.first || {}
    @template.content_tag(:div, :class => "row select time_zone") do
      build_label(name, "select", options[:label]) + time_zone_select_without_div(name, choices, build_example(:example, options)) + build_hint(options[:hint])
    end
  end
  alias_method_chain :time_zone_select, :div
  
  def country_select_with_div(name, *args)
    options = args.first || {}
    @template.content_tag(:div, :class => "row select country") do
      build_label(name, "select", options[:label]) + country_select_without_div(name, build_example(:example, options)) + build_hint(options[:hint])
    end
  end
  alias_method_chain :country_select, :div
  
  def submit(*args)
    block_output = (yield).to_s if block_given?
    block_output = " or " + block_output unless block_output.blank?
    text = super(*args)
    @template.content_tag(:div, :class => "save_actions") do
       text + block_output.to_s
    end
  end
  
  protected
    
    def build_example(example, options)
      return options if options[example].nil?
      options.merge(:title => options[example], :class => "example")
    end
    
    def build_label(label, name, custom_label = nil)
      custom_label ||= label.to_s.humanize
      #@template.content_tag(:label, custom_label.to_s, :for => "#{@object_name}_#{label}", :class => "#{name}_label")
      @template.label(@object_name, label, custom_label.to_s, :class => "#{name}_label")
    end
    
    def build_hint(hint_text = nil)
      return "" if hint_text.nil?
      @template.content_tag(:span, "#{hint_text.to_s}", :class => "hint")
    end
  
end
