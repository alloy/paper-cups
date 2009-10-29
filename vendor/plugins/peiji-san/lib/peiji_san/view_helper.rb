module PeijiSan
  # Include this module into your view helper module, for instance
  # ApplicationController, for super paginating cow powers.
  #
  # Optionally define the peiji_san_options method in your helper to override
  # the default options.
  #
  # Example:
  #
  #   @collection = Member.active.page(2)
  #
  #   <% pages_to_link_to(@collection).each do |page %>
  #     <%= page.is_a?(String) ? page : link_to_page(page) %>
  #   <% end %>
  module ViewHelper
    # The default options for link_to_page and pages_to_link_to.
    DEFAULT_PEIJI_SAN_OPTIONS = {
      # For link_to_page
      :page_parameter => :page,
      :anchor => :explore,
      :current_class => :current,
      # For pages_to_link_to
      :max_visible => 11,
      :separator => '…'
    }
    
    # Override this method in your helper to override default values:
    #
    #   def peiji_san_options
    #     { :max_visible => 7 }
    #   end
    def peiji_san_options
    end
    
    # Creates a link using +link_to+ for a page in a pagination collection. If
    # the specified page is the current page then its class will be `current'.
    #
    # Options:
    #   [:page_parameter]
    #     The name of the GET parameter used to indicate the page to display.
    #     Defaults to <tt>:page</tt>.
    #   [:current_class]
    #     The CSS class name used when a page is the current page in a pagination
    #     collection. Defaults to <tt>:current</tt>.
    def link_to_page(page, paginated_set, options = {}, html_options = {})
      page_parameter = peiji_san_option(:page_parameter, options)
      url_options = (page == 1 ? controller.params.except(page_parameter) : controller.params.merge(page_parameter => page))
      url_options[:anchor] = peiji_san_option(:anchor, options)
      html_options[:class] = peiji_san_option(:current_class, options) if paginated_set.current_page?(page)
      link_to page, url_for(url_options), html_options
    end
    
    # Returns an array of pages to link to. This array includes the separator, so
    # make sure to keep this in mind when iterating over the array and creating
    # links.
    #
    # For consistency’s sake, it is adviced to use an odd number for
    # <tt>:max_visible</tt>.
    #
    # Options:
    #   [:max_visible]
    #     The maximum amount of elements in the array, this includes the
    #     separator(s). Defaults to 11.
    #   [:separator]
    #     The separator string used to indicate a range between the first or last
    #     page and the ones surrounding the current page.
    #
    # Example:
    #
    #   collection = Model.all.page(40)
    #   collection.page_count # => 80
    #
    #   pages_to_link_to(collection) # => [1, '…', 37, 38, 39, 40, 41, 42, 43, '…', 80]
    def pages_to_link_to(paginated_set, options = {})
      current, last = paginated_set.current_page, paginated_set.page_count
      max = peiji_san_option(:max_visible, options)
      separator = peiji_san_option(:separator, options)
      
      if last <= max
        (1..last).to_a
      elsif current <= ((max / 2) + 1)
        (1..(max - 2)).to_a + [separator, last]
      elsif current >= (last - (max / 2))
        [1, separator, *((last - (max - 3))..last)]
      else
        offset = (max - 4) / 2
        [1, separator] + ((current - offset)..(current + offset)).to_a + [separator, last]
      end
    end
    
    private
    
    def peiji_san_option(key, options)
      if value = options[key]
        value
      elsif (user_options = peiji_san_options) && user_options[key]
        user_options[key]
      else
        DEFAULT_PEIJI_SAN_OPTIONS[key]
      end
    end
  end
end