# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'livereload' do
  watch(%r{javascripts/.+\.js$})
  watch(%r{index\.html$})
  watch(%r{css/.+\.css$})
end

guard 'coffeescript', :output => 'javascripts', :source_map => true do
  watch(/^coffeescripts\/(.*)\.coffee/)
  callback(:run_on_modifications_end) { puts '-'*100; 
  FileUtils.cp_r('coffeescripts', 'javascripts')
  }
  callback(:reload_end) { puts '+'*1000}
end
 
guard 'coffeescript', :output => 'spec/javascripts' do
  watch(/^spec\/coffeescripts\/(.*)\.coffee/)
end
 