require 'ostruct'
require 'time'

module Mifo

  STORAGE = File.join(File.dirname(__FILE__), 'posts')

  module BlogHelper
    def markdown(text)
      Kramdown::Document.new(text, :auto_ids => false).to_html
    end
    def text(t)
      Nokogiri::HTML(t).text
    end
  end

  module PostClassMethods
    def latest(count=10)
      all.reverse[0..(count-1)]
    end

    def all
      Dir.glob(File.join(STORAGE, '*.md')).collect do |f|
        self.new(File.basename(f).gsub(/\.md$/,''))
      end.to_a.sort { |a,b| a.last_updated <=> b.last_updated }
    end

    def where(opts={})
      self.new(opts[:permalink]) if opts[:permalink]
    end
  end

  class Post
    extend PostClassMethods

    attr_reader :title, :body, :last_updated, :permalink

    def initialize(permalink)
      @permalink = permalink.to_s.strip
      @raw_content = File.read(
        File.join(Mifo::STORAGE, @permalink + '.md')
      ).each_line.to_a
      metadata do |m|
        @title = m.title
        @last_updated = DateTime.parse(m.last_updated || m.updated)
      end
    end

    def body
      @body ||= @raw_content[end_index+1..-1].join
    end

    private

    def metadata
      data = @raw_content[0..end_index].inject({}) do |result, line|
        property, value = line.split(':')
        result[property.intern] = value
        result
      end
      yield OpenStruct.new(data) if block_given?
    end

    def end_index
      @raw_content.index { |l| l =~ /^(\#+)$/ } || 0
    end

  end

  class Site < Sinatra::Base

    error Errno::ENOENT do
      status 404
    end

    helpers BlogHelper

    get '/' do
      @posts = Post.latest
      haml :index
    end

    get %r{/(rss|atom|articles)(.xml)?} do
      content_type 'text/xml;charset=utf-8'
      @posts = Post.latest
      haml(:rss, :format => :xhtml, :escape_html => true, :layout => false)
    end

    get '/:permalink' do
      @post = Post.where(:permalink => params[:permalink])
      haml :show, :ugly => true
    end

  end
end
