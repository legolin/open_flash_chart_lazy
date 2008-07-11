module ActionView
  module Helpers
    module OpenFlashChartLazyHelper
      def remote_graph(dom_id,options={})
        javascript_tag(swf_object(dom_id,options)).concat(content_tag("div","",:id=>"#{dom_id}"))
      end
      def swf_object(dom_id,options={})
        options.merge!({:width=>300,:height=>150})
        remote = ""
        remote = ",{'data-file':'#{options[:route]}'}" if options[:route]
        "swfobject.embedSWF('/open-flash-chart.swf','#{dom_id}','#{options[:width]}','#{options[:height]}','9.0.0','expressInstall.swf'#{remote});"
      end
      def inline_graph(graph,options={})
        dom_id = "lazy_graph#{Time.now.usec}"
        script = <<-EOS
        function open_flash_chart_data()
        {
            return JSON.stringify(data);
        }
        function findSWF(movieName) {
          if (navigator.appName.indexOf("Microsoft")!= -1) {
            return window[movieName];
          } else {
            return document[movieName];
          }
        }
        var data = #{graph.to_graph_json};
        EOS
        content_tag("div","",:id=>"#{dom_id}").concat(javascript_tag(swf_object(dom_id,options)).concat(javascript_tag(script)))
      end
    end
  end
end