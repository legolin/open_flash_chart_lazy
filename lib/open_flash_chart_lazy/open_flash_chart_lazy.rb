module OpenFlashChartLazy
  # a collaborator of chart objects to handle data series and labels 
  class Serie
    attr_accessor :data
    attr_accessor :items
    attr_accessor :labels
    attr_accessor :keys
    attr_accessor :options
    attr_accessor :values
    attr_accessor :title
    attr_accessor :max
    attr_accessor :min
    attr_accessor :steps
    def initialize(data,options={})
      @data = data
      # the labels
      @labels = []
      # for time periods and hash
      @keys = []
      # min and max
      @min = 0
      @max = 0
      #default options
      @steps = 1
      @options = {:date_label_formatter=>"%b %Y",:date_key_formatter=>"%Y-%m",:title=>"Untitled"}
      if @data.is_a?(Hash)
        @items = data.length
      else
        @options.merge!({:items => data.length})
        @items = @options.merge!(options)[:items]
      end
      # set title
      @title = options[:title]
      # the values
      @values = [0] * @items
      fill_keys_and_labels
      fill_values
      
    end
    def time_serie?
      !@options[:start_date].nil?
    end
    private
    def fill_keys_and_labels
      @items.times do |i|
        if @options[:start_date]
          new_period = Date.new(@options[:start_date].year,@options[:start_date].month,@options[:start_date].day) >> i
          period = Time.mktime(new_period.year,new_period.month,new_period.day)
          @labels[i] = period.strftime(@options[:date_label_formatter])
          @keys[i] = period.strftime(@options[:date_key_formatter])
        elsif @data.is_a?(Hash)
          @labels[i] = "#{@data.keys[i]}"
          @keys[i] = @data.keys[i]
        elsif @data.is_a?(Array)
          if @data[i].is_a?(Array) and @data[i].length > 1
            @labels[i] = "#{@data[i][0]}"
          else
            @labels[i] = "#{i}"
          end
        else
          @labels[i] = "#{i}"
        end
      end
    end
    def fill_values
      if time_serie?
        @data.each do |element|
          period = "#{element[0].split('-')[0]}-#{element[0].split('-')[1].rjust(2,'0')}" unless element[0].nil?
          if @keys.index(period)
            @values[@keys.index(period)]=0
            if element[1]
              @min = (@min > element[1]) ? element[1] : @min
              @max = (@max < element[1]) ? element[1] : @max
              @steps = (@max - @min) / 5
              @values[@keys.index(period)]=element[1]
            end
          end
        end
      else
        case @data.class.name
        when "Array"
          @data.each_with_index do |data,i|
            if data.is_a?(Array)
              if data.length>1 and data[1]
                @values[i]=data[1] 
              elsif data.length==1
                @values[i]=data[0]
              end
            else
              @values[i]=data
            end
          end
        when "Hash"
          @values = @data.values
        end
      end
    end
  end

  class Graph
    attr_accessor :series
    attr_accessor :elements
    attr_accessor :title
    attr_accessor :x_axis
    attr_accessor :y_axis
    def initialize(title="Untitled")
      @series = []
      @elements = []
      @title = {:text=>title}
      @y_axis = {}
      @x_axis = {:labels => []}
    end
    def method_missing(method, value)
      self.instance_variable_set( "@#{method.to_s[0..-2]}".to_sym,value)
    end
  end

  class Bar < Graph
  
    LINE_COLORS = %w{#33ff33 #ff33ff #dd00ee}
    EXCLUDED_ATTRIBUTES = %w{series}
  
    def add_serie(serie,options={})
      @elements << {:type=>"bar",:text=>serie.title}
      @elements.last.merge!(options)
      @series << serie
      @elements.last[:values] = serie.values
      @x_axis[:labels] = {:labels => @series.last.labels }
    end
    def to_graph_json
      self.to_json(:except=>EXCLUDED_ATTRIBUTES)
    end
  end

  class Bar3d < Graph
  
    LINE_COLORS = %w{#33ff33 #ff33ff #dd00ee}
    EXCLUDED_ATTRIBUTES = %w{series}
  
    def add_serie(serie,options={})
      @elements << {:type=>"bar_3d",:text=>serie.title}
      @elements.last.merge!(options)
      @series << serie
      @elements.last[:values] = serie.values
      @x_axis[:labels] = {"3d"=>10,:colour=>"#909090",:labels => @series.last.labels }
    end
    def to_graph_json
      self.to_json(:except=>EXCLUDED_ATTRIBUTES)
    end
  end


  class Line < Graph
    attr_accessor :series
    attr_accessor :elements
    attr_accessor :title
    attr_accessor :x_axis
    attr_accessor :y_axis
  
    EXCLUDED_ATTRIBUTES = %w{series}
    LINE_COLORS = %w{#33ff33 #ff33ff #dd00ee}
    def initialize(title="Untitled")
      super
      @y_axis = {:min =>0,:max=>0,:steps=>1}.merge(@y_axis)
    end
  
    def add_serie(serie,options={})
      @elements << {:text=>serie.title,:type=>"line_dot",:width=>4,:dot_size=>5}
      @elements.last.merge!(options)
      @series << serie
      @elements.last[:values] = serie.values
      # the first serie will hold the x-axis labels
      @x_axis[:labels] = {:labels => @series.last.labels }
      @y_axis[:min] = (@y_axis[:min]>serie.min) ? serie.min : @y_axis[:min]
      @y_axis[:max] = (@y_axis[:max]<serie.max) ? serie.max : @y_axis[:max]
      @y_axis[:steps] = (@y_axis[:steps]<serie.steps) ? serie.max : @y_axis[:steps]
      @elements.last[:colour]=LINE_COLORS[elements.length-1] if LINE_COLORS[elements.length-1]
    end
    def to_graph_json
      self.to_json(:except=>EXCLUDED_ATTRIBUTES)
    end
  end
  class Pie < Graph
  
    EXCLUDED_ATTRIBUTES = %w{series}
    PIE_COLORS = [ "#d01f3c", "#356aa0", "#C79810" ]
    def initialize(title="Untitled")
      super
      @x_axis = "null"
    end
    def add_serie(serie,options={})
      @elements << {:text=>serie.title,
          :type=>"pie",
          :border=>2,
          :alpha=>0.6,
          :start_angle=>35,
          :animate => true,
          :colours => PIE_COLORS}
      @elements.last.merge!(options)
      @elements.last[:values] = []
      @series << serie
      serie.values.each_with_index do |v,i|
        @elements.last[:values]<< {:text => serie.labels[i], :value => v}
      end
    end
    def to_graph_json
      self.to_json(:except=>EXCLUDED_ATTRIBUTES)
    end
  end
end