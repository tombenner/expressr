module Expressr
  module Utils
    # From ActiveSupport
    def constantize(camel_cased_word)
      names = camel_cased_word.split('::')

      # Trigger a builtin NameError exception including the ill-formed constant in the message.
      Object.const_get(camel_cased_word) if names.empty?

      # Remove the first blank element in case of '::ClassName' notation.
      names.shift if names.size > 1 && names.first.empty?

      names.inject(Object) do |constant, name|
        if constant == Object
          constant.const_get(name)
        else
          candidate = constant.const_get(name)
          next candidate if constant.const_defined?(name, false)
          next candidate unless Object.const_defined?(name)

          # Go down the ancestors to check it it's owned
          # directly before we reach Object or the end of ancestors.
          constant = constant.ancestors.inject do |const, ancestor|
            break const    if ancestor == Object
            break ancestor if ancestor.const_defined?(name, false)
            const
          end

          # owner is in Object, so raise
          constant.const_get(name, false)
        end
      end
    end
    module_function :constantize

    def standardize_content_type(content_type)
      canonicalized_types = {
        'text' => 'text/plain',
        'html' => 'text/html',
        'json' => 'application/json'
      }
      canonicalized_types[content_type] || content_type
    end
    module_function :standardize_content_type
  end
end
