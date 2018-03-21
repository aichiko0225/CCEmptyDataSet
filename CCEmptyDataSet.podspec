Pod::Spec.new do |s|
  s.name             = 'CCEmptyDataSet'
  s.version          = '0.1.0'
  s.summary          = 'CCEmptyDataSet.'  #这里要修改下

 s.description      = <<-DESC
        CCEmptyDataSet. #这里也要修改下
                       DESC

  s.homepage         = 'https://github.com/aichiko0225/CCEmptyDataSet'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  # s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.license      = "MIT"
  s.author           = { 'ash' => 'aichiko66@163.com' }
  s.source           = { :git => 'https://github.com/aichiko0225/CCEmptyDataSet.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'CCEmptyDataSet/CCEmptyDataSet/*'
  
end