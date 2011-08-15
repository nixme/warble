# Tilt engine class for Handlebars templates. Works with Sprocket's
# JSTProcessor template
#
class HandlebarsTemplate < Tilt::Template
  include ActionView::Helpers::JavaScriptHelper

  def prepare
  end

  def evaluate(scope, locals, &block)
    "Handlebars.compile(\"#{escape_javascript(data)}\");"
  end
end
