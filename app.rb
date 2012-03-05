require 'ostruct'
require 'digest/sha1'
require 'time'
require 'nokogiri'

require 'bundler/setup'
Bundler.require(:default)

module Mifo

  STORAGE = File.join(File.dirname(__FILE__), 'posts')

  class Post
    attr_reader :title, :body, :last_updated, :permalink

    def self.latest(count=10)
      all.reverse[0..(count-1)]
    end

    def self.all
      Dir.glob(File.join(STORAGE, '*.md')).collect do |f|
        self.new(File.basename(f).gsub(/\.md$/,''))
      end.to_a.sort { |a,b| a.last_updated <=> b.last_updated }
    end

    def self.by_permalink(permalink)
      self.new(permalink)
    end

    def initialize(permalink)
      @permalink = permalink.to_s.strip
      @raw_content = File.read(File.join(Mifo::STORAGE, @permalink + '.md'))
      meta_data do |m|
        @title = m.title
        @last_updated = DateTime.parse(m.last_updated || m.updated)
      end
    end

    def body
      @raw_content.each_line.to_a[metadata_end_index+1..-1].join
    end

    def sha1
      Digest::SHA1.hexdigest(title+body)
    end

    private

    def meta_data
      data = @raw_content.each_line.to_a[0..metadata_end_index].inject({}) do |result, line|
        property, value = line.split(':')
        result[property.intern] = value
        result
      end
      yield OpenStruct.new(data) if block_given?
    end

    def metadata_end_index
      @raw_content.each_line.to_a.index { |l| l =~ /^(\#+)$/ } || 0
    end

  end

  class Site < Sinatra::Base

    configure :production do
      use Rack::Cache
      before do
        expires 500, :public,  :must_revalidate
      end
    end

    error Errno::ENOENT do
      status 404
    end

    configure do
      enable :logging
    end

    helpers do
      def markdown(text)
        m = Redcarpet::Markdown.new(Redcarpet::Render::HTML, :autolink => true, :space_after_headers => true)
        m.render(text)
      end

      def text(t)
        Nokogiri::HTML(t).text
      end
    end

    get '/' do
      @posts = Post.latest
      etag sha1(@posts.map { |p| p.sha1 }.join )
      haml :index
    end

    get '/(rss|articles.xml|atom.xml)' do
      @posts = Post.latest
      etag sha1(@posts.map { |p| p.sha1 }.join )
      content_type 'application/rss+xml'
      haml(:rss, :format => :xhtml, :escape_html => true, :layout => false)
    end

    get '/:permalink' do
      @post = Post.by_permalink(params[:permalink])
      etag @post.sha1
      haml :show
    end

    private

    def sha1(obj)
      Digest::SHA1.hexdigest(obj)
    end

  end
end
