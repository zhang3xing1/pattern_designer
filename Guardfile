# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'livereload' do
  watch(%r{javascripts/.+\.js$})
  watch(%r{index\.html$})
  watch(%r{css/.+\.css$})
end

guard 'coffeescript', :output => 'javascripts' do
  watch(/^coffeescripts\/(.*)\.coffee/)
end
 
guard 'coffeescript', :output => 'spec/javascripts' do
  watch(/^spec\/coffeescripts\/(.*)\.coffee/)
end
 