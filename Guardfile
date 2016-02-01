# A sample Guardfile
# More info at https://github.com/guard/guard#readme

#guard 'cucumber' do
#  watch(%r{^features/.+\.feature$})
#  watch(%r{^features/support/.+$})          { 'features' }
#  watch(%r{^features/step_definitions/(.+)_steps\.rb$}) { |m| Dir[File.join("**/#{m[1]}.feature")][0] || 'features' }
#end

guard 'shotgun', :server => 'puma' do
  watch %r{^(app|lib)/.*\.rb}
  watch %r{^(views)/.*\.erb}
  watch 'config.ru'
end
