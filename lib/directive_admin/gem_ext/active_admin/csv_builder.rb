module ActiveAdmin
  class CSVBuilder

    def build(view_context, receiver)
      options = ActiveAdmin.application.csv_options.merge self.options

      collection = view_context.send(:collection)
      select = collection.instance_variable_get(:@select)

      if byte_order_mark = options.delete(:byte_order_mark)
        receiver << byte_order_mark
      end

      receiver << CSV.generate_line(select, options)

      collection.each do |row|
        values = row.values_at(*select).collect{|x| x.respond_to?(:strftime) ? x.to_s(:db) : x.to_s}
        receiver << CSV.generate_line(values, options)
      end
    end

  end
end
