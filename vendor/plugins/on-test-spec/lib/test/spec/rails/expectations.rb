module Test
  module Spec
    module Rails
      module Helpers
        def self.inspect_records(records)
          "[#{records.map { |record| "#{record.class}[#{record.id}]" }.join(', ')}]"
        end
      end
      
      module ShouldExpectations
        # Test that we were redirected somewhere:
        #   should.redirect
        #
        # Test that we were redirected to a specific url:
        #   should.redirect :controller => 'foo', :action => 'bar'
        # or:
        #   should.redirect_to :controller => 'foo', :action => 'bar', :secure => true
        def redirect(*args)
          if args.empty?
            test_case.assert_response @object.response.redirected_to, :redirect
          elsif args.length == 1 and args.first.is_a?(String)
            test_case.assert_equal args.first, @object.response.redirected_to
          else
            options = args.extract_options!
            if secure = options.delete(:secure)
              unless secure == true or secure == false
                raise ArgumentError, ":secure option should be a boolean"
              end
            end
            
            @object.instance_eval { test_case.assert_redirected_to *args }
            if secure == true
              test_case.assert @object.response.redirected_to.starts_with?('https:')
            elsif secure == false
              test_case.assert @object.response.redirected_to.starts_with?('http:')
            end
          end
        end
        alias :redirect_to :redirect
        
        # Tests whether a redirect back to the HTTP_REFERER was send.
        #
        #   lambda { delete :destroy, :id => 1 }.should.redirect_back_to(articles_url)
        #   lambda { delete :destroy, :id => 1 }.should.redirect_back_to(:action => :index)
        def redirect_back_to(url_options)
          test_case = eval("self", @object.binding)
          url = test_case.controller.url_for(url_options)
          test_case.controller.request.env["HTTP_REFERER"] = url
          
          block_result = @object.call
          test_case.should.redirect_to(url)
          
          block_result
        end
        
        # Test that the object is valid
        def validate
          test_case.assert_valid @object
        end
        
        # Tests whether the evaluation of the expression changes.
        #
        #   lambda { Norm.create }.should.differ('Norm.count')
        #   lambda { Norm.create; Norm.create }.should.differ('Norm.count', +2)
        #   lambda { Norm.create; Option.create }.should.differ('Norm.count', +2, 'Option.count', +1)
        #
        #   norm = lambda { Norm.create }.should.differ('Norm.count')
        #   norm.name.should == 'Latency'
        def differ(*expected)
          block_binding = @object.send(:binding)
          before = expected.in_groups_of(2).map do |expression, _|
            eval(expression, block_binding)
          end
          
          block_result = @object.call
          
          expected.in_groups_of(2).each_with_index do |(expression, difference), index|
            difference = 1 if difference.nil?
            error = "#{expression.inspect} didn't change by #{difference}"
            test_case.assert_equal(before[index] + difference, eval(expression, block_binding), error)
          end
          
          block_result
        end
        alias change differ
        
        # Tests whether certain pages are cached.
        #
        #   lambda { get :index }.should.cache_pages(posts_path)
        #   lambda { get :show, :id => post }.should.cache_pages(post_path(post), formatted_posts_path(:js, post))
        def cache_pages(*pages, &block)
          if block
            block.call
          else
            @object.call
          end
          cache_dir = ActionController::Base.page_cache_directory
          files = Dir.glob("#{cache_dir}/**/*").map do |filename|
            filename[cache_dir.length..-1]
          end
          test_case.assert pages.all? { |page| files.include?(page) }
        end
        
        # Test two HTML strings for equivalency (e.g., identical up to reordering of attributes)
        def dom_equal(expected)
          test_case.assert_dom_equal expected, @object
        end
        
        # Tests if the array of records is the same, order may vary
        def equal_set(expected)
          message = "#{Helpers.inspect_records(@object)} does not have the same records as #{Helpers.inspect_records(expected)}"
          
          left = @object.map(&:id).sort
          right = expected.map(&:id).sort
          
          test_case.assert(left == right, message)
        end
        
        # Tests if the array of records is the same, order must be the same
        def equal_list(expected)
          message = "#{Helpers.inspect_records(@object)} does not have the same records as #{Helpers.inspect_records(expected)}"
          
          left = @object.map(&:id)
          right = expected.map(&:id)
          
          test_case.assert(left == right, message)
        end
      end
      
      module ShouldNotExpectations
        # Test that an object is not valid
        def validate
          test_case.assert !@object.valid?
        end
        
        # Tests that the evaluation of the expression shouldn't change
        #
        #   lambda { Norm.new }.should.not.differ('Norm.count')
        #   lambda { Norm.new }.should.not.differ('Norm.count', 'Option.count')
        #
        #   norm = lambda { Norm.new }.should.not.differ('Norm.count')
        #   norm.token.should.match /(\d\w){4}/
        def differ(*expected)
          block_binding = @object.send(:binding)
          before = expected.map do |expression|
            eval(expression, block_binding)
          end
          
          block_result = @object.call
          
          expected.each_with_index do |expression, index|
            difference = eval(expression, block_binding) - before[index]
            error = "#{expression.inspect} changed by #{difference}, expected no change"
            test_case.assert_equal(0, difference, error)
          end
          
          block_result
          
        end
        alias change differ
        
        # Test that two HTML strings are not equivalent
        def dom_equal(expected)
          test_case.assert_dom_not_equal expected, @object
        end
        
        # Tests if the array of records is not the same, order may vary
        def equal_set(expected)
          message = "#{Helpers.inspect_records(@object)} has the same records as #{Helpers.inspect_records(expected)}"
          
          left = @object.map(&:id).sort
          right = expected.map(&:id).sort
          
          test_case.assert(left != right, message)
        end
        
        # Tests if the array of records is not the same, order may vary
        def equal_list(expected)
          message = "#{Helpers.inspect_records(@object)} has the same records as #{Helpers.inspect_records(expected)}"
          
          left = @object.map(&:id)
          right = expected.map(&:id)
          
          test_case.assert(left != right, message)
        end
      end
    end
  end
end

Test::Spec::Should.send(:include, Test::Spec::Rails::ShouldExpectations)
Test::Spec::ShouldNot.send(:include, Test::Spec::Rails::ShouldNotExpectations)
