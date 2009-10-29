class JavascriptSanGenerator < Rails::Generator::NamedBase
  def manifest
    record do |m|
      # Library and test directories.
      m.directory File.join('public/javascripts', class_path)
      m.directory File.join('test/javascripts', class_path)

      # Model class, unit test, and fixtures.
      assigns = { :sanitized_file_name => file_name.gsub(/\./, '_') }
      m.template 'library.js',        File.join('public/javascripts', class_path, "#{assigns[:sanitized_file_name]}.js"),
        :assigns => assigns
      m.template 'library_test.js',   File.join('test/javascripts', class_path, "#{assigns[:sanitized_file_name]}_test.js"),
        :assigns => assigns
      m.template 'library_test.html', File.join('test/javascripts', class_path, "#{assigns[:sanitized_file_name]}_test.html"),
        :assigns => assigns
    end
  end
end
