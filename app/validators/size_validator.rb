class SizeValidator < ActiveModel::EachValidator
  include ActionView::Helpers::TextHelper
  def validate_each(record, attribute, value)
    debugger

    # maximumとminimumも追加する。
    if options.has_key?(:in)
      record.errors[attribute] << "should be #{options[:in]} bytes" unless options[:in].include?(value.size) 
    elsif options.has_key?(:with)
      record.errors[attribute] << "should be less than #{pluralize(options[:with],'byte')}" if value.size > options[:with]
    elsif options.has_key?(:maximum)
      record.errors[attribute] << "should be less than #{pluralize(options[:maximum],'byte')}" if value.size > options[:maximum]
    elsif options.has_key?(:minimum)
      record.errors[attribute] << "should be more than #{pluralize(options[:minimum],'byte')}" if value.size < options[:minimum]
    end
  end
end
