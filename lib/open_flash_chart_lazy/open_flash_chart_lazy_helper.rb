module ActionView
  module Helpers
    module OpenFlashChartLazyHelper
      def remote_graph(dom_id,options={},html_options={})
        html_options.merge!({:id=>dom_id})
        javascript_tag(swf_object(dom_id,options)).concat(content_tag("div","",html_options))
      end
      def swf_object(dom_id,options={})
        default_options={:width=>300,:height=>150}
        options = default_options.merge(options)
        source = ""
        source = ",{'data-file':'#{options[:route]}'}" if options[:route]
        source = options[:inline] if options[:inline]
        "swfobject.embedSWF('/open-flash-chart.swf','#{dom_id}','#{options[:width]}','#{options[:height]}','9.0.0','expressInstall.swf'#{source});"
      end
      def inline_graph(graph,dom_id,options={},html_options={})
        var = "lazy#{Time.now.usec}"
        script = <<-EOS
\n
function ofc_ready() {
  // alert('ofc_ready');
}
\n
function data_#{dom_id}() {
  return JSON.stringify(#{var});
}
\n
var #{var} = #{graph.to_graph_json};
\n
EOS
        source = ",{'get-data' : 'data_#{dom_id}'}"
        options.merge!(:inline=>source)
        content_for(:ofcl,javascript_tag(swf_object(dom_id,options).concat(script)))
        content_tag("div","",:id=>"#{dom_id}")
      end
    end
  end
end