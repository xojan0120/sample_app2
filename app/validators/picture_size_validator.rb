class PictureSizeValidator < ActiveModel::Validator
  # 下記のincludeはpluralizeを使うため。
  include ActionView::Helpers::TextHelper

  def validate(record)
    default_limit = 5.megabytes

    if options.size.zero?
      if record.picture.size > default_limit
        record.errors[:picture] << "should be less than #{pluralize(default_limit, 'byte')}"
      end
    end

    if options.has_key?(:minimum)
      if record.picture.size < options[:minimum]
        record.errors[:picture] << "should be more than #{pluralize(options[:minimum], 'byte')}"
      end
    end

    if  options.has_key?(:maximum) 
      if record.picture.size > options[:maximum]
        record.errors[:picture] << "should be less than #{pluralize(options[:maximum], 'byte')}"
      end
    end
  end
end
