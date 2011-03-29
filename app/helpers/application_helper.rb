require 'pp'

module ApplicationHelper
  include AuthHelper
  include CurriculumHelper
  include EventsHelper

  def devise_error_messages_translated!
    return "" if resource.errors.empty?

    messages = resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
    sentence = I18n.t "activerecord.errors.template.header", :count => resource.errors.count
    html = <<-HTML
    <div id="error_explanation">
      <h2>#{sentence}</h2>
      <ul>#{messages}</ul>
    </div>
    HTML

    html.html_safe
  end

  def content_box(title_strong = nil, title = nil, border = false, &block)
    title_str = ""
    title_str += "<span>#{title_strong}</span>" unless title_strong.blank?
    title_str += "<span>#{title}</span>" unless title.blank?
    title_str = "<h2>#{title_str}</h2>" unless title_str.blank?
    if border
      content = <<HTML
    		<div class="box">
					<div class="border-right">
						<div class="border-bot">
							<div class="border-left">
								<div class="left-top-corner">
									<div class="right-top-corner">
										<div class="inner">
											#{title_str}
											#{capture(&block)}
										</div>
									</div>
								</div>
							</div>
						</div>
					</div>
				</div>
HTML
    else
      content = <<HTML
        <div class="inside">
					#{title_str}
					#{capture(&block)}
				</div>
HTML
    end
    content.html_safe
  end

  #(name, {options of url_for}
  #modified from link_to
  def styled_button(*args)
    name = args[0]
    args.delete_at(0)
    if args.last.is_a?(Hash) && (args.length > 1)
      args.last[:class] = 'link1'
    else
      args << {:class => 'link1'}
    end
    pp args

    content = '<div class="wrapper">'
    content += link_to(*args) do
      safe_concat <<HTML
        <span><span>#{name}</span></span>
HTML
    end
    content += '</div>'

    content.html_safe
  end

  def submit_button(form, id, text)
    content = <<HTML
    <div class="wrapper"><a href="#" class="link1" onclick="if($('#{id}').onsubmit==null||$('#{id}').onsubmit()){$('#{id}').submit();}"><span><span>#{text}</span></span></a></div>
HTML

    if form.nil?
      content += submit_tag(text, :style => "width:0px; height:0px; border:0px;")
    else
      content += form.submit(text, :style => "width:0px; height:0px; border:0px;")
    end
    
    content.html_safe
  end

  def header_announcement
    #check confirmation for employee_no
    user_id_rec = current_user.user_identifier.find(:first,
      :conditions => ["login_type = ?", UserIdentifier::TYPE_EMPLOYEE_NO])

    if !user_id_rec.nil?
      @not_confirmed = !user_id_rec.confirmed
      username = user_id_rec.login_value
      username = username.delete(company_domain(current_user) + ".")
      @auth_path = auth_path(username, root_url)
    end

    @curriculum_empty = curriculum_empty?(current_user)
    @renren_url_empty = (current_user.user_extra.nil? || current_user.user_extra.renren_id.blank?)

    render :partial=>"shared/header_announcement"
  end

  def sidebar_announcement
    render :partial=>"shared/sidebar_announcement"
  end

  def user_profile(user, renren_url = nil, photo_url = nil, department = nil)
    @name = user.friendly_name
    if (renren_url && photo_url && department)
      @renren_url = renren_url
      @photo_url = photo_url
      @department = department
      @can_be_selected = true
    else
      @renren_url = user.user_extra.renren_url if (user.user_extra && !user.user_extra.hide_profile)
      @photo_url = user.user_extra.photo_url if (user.user_extra && !user.user_extra.hide_profile)
      @department = user.user_extra.department if (user.user_extra && !user.user_extra.hide_profile)
      @unconfirmed = (@renren_url && @photo_url && user.user_extra.profile_status != User::PROFILE_CONFIRMED)
    end

    render :partial => 'shared/user_profile'
  end

  def rand_note
    @note = NOTES[rand(NOTES.size)]
    render :partial => 'shared/note'
  end

  FUNCTION_DESCRIPTIONS = ['让您随时随地查看课表，并找到同上一节课的Ta',
    '通过用户的反馈告诉您哪节课有点名，并主动发送报警邮件',
    '让您更轻松地通过分享功能与朋友、同学们一起参加活动，寻找大家共同空余的时间并且方便掌握大家的反馈']

  def rand_function_description
    return FUNCTION_DESCRIPTIONS[rand(FUNCTION_DESCRIPTIONS.size)]
  end

  def function_descriptions
    return FUNCTION_DESCRIPTIONS
  end

end
