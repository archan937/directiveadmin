module DirectiveAdmin
  class ResourceMock
    extend Forwardable

    class Ransacker < Struct.new(:type); end

    def_delegators :data, *Enumerable.instance_methods, :num_pages, :total_pages, :current_page, :size, :total_count

    def self.ransackers(options = {})
      (@ransackers ||= {}).tap do |ransackers|
        options.each do |name, type|
          ransackers[name.to_s] = Ransacker.new(type)
        end
      end
      @ransackers
    end

    def self._ransackers
      ransackers
    end

    def self.ransack(params = {}, options = {})
      new params, options
    end

    def self.connection
      self
    end

    def self.qry(*args)
      args[0][:instance]
    end

    def self.column_names; []; end
    def self.columns_hash; {}; end
    def self.quote_column_name(name); name; end
    def self.reflections; {}; end

    def initialize(params = {}, options = {})
      @params = params
      @options = options
    end

    def klass
      self.class
    end

    def result
      self
    end

    def page(number)
      @page = number
      self
    end

    def per(number)
      @per = number
      self
    end

    def reorder(*args)
      @order = args
      self
    end

    def qry_options(*args)
      options = args.extract_options!
      @select = (options[:select] || args).flatten
      {:instance => self}
    end

    def data
      @data ||= Kaminari.paginate_array(fetch_data(@select, @order)).page(@page).per(@per) if @select
    end

    def limit_value
      @per
    end

    def fetch_data(select, order)
      raise NotImplementedError
    end

    def is_a?(klass)
      (data && (klass == Array)) || super
    end

    def last
      self
    end

    def object
      self
    end

    def method_missing(name, *args)
      if self.class._ransackers.key?(name.to_s)
        @params[name]
      else
        super
      end
    end

  end
end
