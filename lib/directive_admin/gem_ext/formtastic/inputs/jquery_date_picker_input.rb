module Formtastic
  module Inputs
    class JqueryDatePickerInput < StringInput
      include Base::JqueryDriven

    private

      def inputs_html
        template.text_field_tag expand_name("date"), object.send(method).try(:strftime, "%d-%m-%Y"), input_html_options
      end

      def expand_name(name)
        "#{object_name}[#{method}][#{name}]"
      end

      def script_html
        (
        <<-HTML
          <script>
            $('##{dom_id}').datetimepicker({
              timepicker: false,
              format: 'd-m-Y',
              step: 15
            }).addClass('datepicker');
          </script>
        HTML
        ).html_safe
      end

    end
  end
end
