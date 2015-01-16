module Formtastic
  module Inputs
    class JqueryTimePickerInput < StringInput
      include Base::JqueryDriven

    private

      def inputs_html
        template.text_field_tag expand_name("time"), object.send(method).try(:strftime, "%H:%M"), input_html_options
      end

      def expand_name(name)
        "#{object_name}[#{method}][#{name}]"
      end

      def script_html
        (
        <<-HTML
          <script>
            $('##{dom_id}').datetimepicker({
              datepicker: false,
              format: 'H:i',
              step: 15
            }).addClass('timepicker');
          </script>
        HTML
        ).html_safe
      end

    end
  end
end
