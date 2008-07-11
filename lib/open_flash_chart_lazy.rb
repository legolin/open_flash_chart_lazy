require 'open_flash_chart_lazy/open_flash_chart_lazy'
require 'open_flash_chart_lazy/open_flash_chart_lazy_helper'

ActionView::Base.class_eval do
  include ActionView::Helpers::OpenFlashChartLazyHelper
end

