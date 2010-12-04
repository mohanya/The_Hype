module Spec
  module Rails
    module Matchers
      class BeValid  #:nodoc:

        def matches?(model)
          @model = model
          @model.valid?
        end

        def failure_message
          "#{@model.class} expected to be valid but had errors:\n  #{@model.errors.full_messages.join("\n  ")}"
        end

        def negative_failure_message
          "#{@model.class} expected to have errors, but it did not"
        end

        def description
          "be valid"
        end

      end

      def be_valid
        BeValid.new
      end
    end
  end
end