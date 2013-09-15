#
# Distributed with Rails Date Kit
# http://www.methods.co.nz/rails_date_kit/rails_date_kit.html
#
# Author:  Stuart Rackham <srackham@methods.co.nz>
# License: This source code is released under the MIT license.
#
module DateHelper

  # Rails text_field helper plus drop-down calendar control for date input. Same
  # options as text_field plus optional :format option which accepts
  # same date display format specifiers as calendar_open() (%d, %e, %m, %b, %B, %y, %Y).
  # If the :format option is not set the the global Rails :default date format
  # is used or failing that  '%d %b %Y'.
  #
  # Explicitly pass it the date value to ensure it is formatted with desired format.
  # Example:
  #
  # <%= date_field('person', 'birthday', :value => @person.birthday) %>
  #
  def date_field(object_name, method, options={})
    format = options.delete(:format) ||
             Date::DATE_FORMATS[:default] ||
             '%d %b %Y'
    if options[:value].is_a?(Date)
      options[:value] = options[:value].to_s
    end
    months = Date::MONTHNAMES[1..12].collect { |m| "'#{m}'" }
    months = '[' + months.join(',') + ']'
    options = {:onfocus => "this.select();calendar_open(this,{format:'#{format}',images_dir:'/images',month_names:#{months}})",
               :onclick => "event.cancelBubble=true;this.select();calendar_open(this,{format:'#{format}',images_dir:'/images',month_names:#{months}})",
              }.merge(options);
    text_field object_name, method, options
  end

end
