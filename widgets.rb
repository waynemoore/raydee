require_relative "./services.rb"
require 'mechanize'

class ZenBroadbandWidget < WidgetService

  def initialize
    super "zenbroadband"
    @agent = Mechanize.new
  end

  def data
    # login
    # extract
    {
      :updated => Time.new,
      :percent_used => "23",
      :downloaded => "56",
      :remaining => "44",
    }
  end

  def login
    page = fetch_page 'https://myaccount.zen.co.uk/sign-in.aspx'
    form = page.form("aspnetForm")
    form["ctl00$ctl00$ContentPlaceholderColumnOne$PageContent$signIn$txtUsername"] = @config[:username]
    form["ctl00$ctl00$ContentPlaceholderColumnOne$PageContent$signIn$txtPassword"] = @config[:password]
    @agent.submit(form, form.buttons.first)
  end

  def extract
    page = fetch_page "https://portal.zen.co.uk/PageLoader.aspx?PageCategory=Home&PageID=PortalHome"
    {
      :updated => Time.new,
      :percent_used => page.search("#ctl00_ctl00_ContentPlaceholderColumnTwo_ContentPlaceholderPageContent_PageContentControl_lblDownloadUsageUsedPercentage").text,
      :downloaded => page.search("#ctl00_ctl00_ContentPlaceholderColumnTwo_ContentPlaceholderPageContent_PageContentControl_lblUsageUsed").text,
      :remaining => page.search("#ctl00_ctl00_ContentPlaceholderColumnTwo_ContentPlaceholderPageContent_PageContentControl_lblUsageRemaining").text
    }
  end

  def fetch_page url
    page = @agent.get(url)
  end

end
