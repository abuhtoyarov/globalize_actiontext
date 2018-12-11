module GlobalizeActiontext
  module ActionText
    def setup_translates!(options)
      super

      self.after_initialize do
        reflect_has_one = self.class.reflect_on_all_associations(:has_one)
        rich_text_attributes = reflect_has_one.map(&:name).map { |name| name.to_s.gsub('rich_text_', '') }.compact.join(', ')

        self.class.translation_class.class_eval do
          attribute rich_text_attributes
          has_rich_text rich_text_attributes

          rich_text_attributes.split(',').each do |method_name|
            define_method "#{method_name}=" do |value|
              self.content.body = value

              return unless public_send(method_name).changed?

              attribute_will_change! method_name
            end
          end
        end
      end
    end
  end
end

ActiveRecord::Base.singleton_class.prepend(GlobalizeActiontext::ActionText)