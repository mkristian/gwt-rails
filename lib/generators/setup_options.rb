require 'yaml'
module Gwt
  module Generators
    module SetupOptions

      def setup_options(opts = self.options)
        opts = opts.dup
        self.options = opts
        file = File.join('config', 'gwt.yml')
        if File.exists?(file)
          c = YAML.load_file(file)
          if c
            c.each do |k,v|
              opts[k] = v if opts[k].nil?
            end
          end
        end
        if (opts[:cache] || opts[:store]) && opts[:singleton]
          say :warning, "singleton can not have store or cache (yet)"
        end
        opts[:timestamps]   = true if opts[:optimistic]
        opts[:cache]        = true if opts[:store]
        opts[:cache]        = false if opts[:singleton]
        opts[:store]        = false if opts[:singleton]
        opts[:place]        = true if opts[:menu]
        opts[:view]         = true if opts[:place]
        opts[:editor]       = true if opts[:view]
        opts[:gin]          = true if opts[:place]
        opts[:event]        = true if opts[:cache]
        opts[:rest_service] = true if opts[:cache]
        say_status :options, "#{opts.inspect}", :white
        opts.freeze
      end
    end
  end
end
