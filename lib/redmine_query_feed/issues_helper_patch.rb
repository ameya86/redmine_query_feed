require_dependency 'issues_helper'

module RedmineQueryFeed::IssuesHelperPatch
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods) # obj.method

    base.class_eval do
      alias_method_chain :query_links, :feed
    end
  end

  module InstanceMethods # obj.method
    def query_links_with_feed(title, queries)
      links_str = query_links_without_feed(title, queries)
      return links_str if links_str.blank?

      links = links_str.chomp[0..-6].split(/\n/)
      title_tag = links.shift

      link_with_feeds = []
      url_params = {
        :controller => 'issues',
        :action => 'index',
        :project_id => @project.try(:identifier),
        :key => User.current.rss_key,
        :format => 'atom',
      }
      queries.each_with_index do |query, index|
        link_with_feeds << links[index][0..-6] << link_to('', url_params.merge(:query_id => query.id), :class => 'atom') << '</li>'
      end

      link_with_feeds.unshift(title_tag)
Rails.logger.info link_with_feeds.join("\n")

      return link_with_feeds.join("\n").html_safe
    end
  end
end

IssuesHelper.send(:include, RedmineQueryFeed::IssuesHelperPatch)
