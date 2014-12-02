module Formtastic
  module Inputs
    module Base
      module JqueryDriven

        def to_html
          input_wrapping do
            label_html << inputs_html << script_html
          end
        end

      private

        def inputs_html
          raise NotImplementedError
        end

        def dom_id
          @dom_id ||= SecureRandom.hex(10)
        end

        def jquery_method
          self.class.name.demodulize.gsub(/(^Jquery|Input$)/, "").gsub(/^(.)/){ $1.downcase }
        end

        def script_html
          (
          <<-HTML
            <script>
              $('##{dom_id}').#{jquery_method}();
            </script>
          HTML
          ).html_safe
        end

      end
    end
  end
end
