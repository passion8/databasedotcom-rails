module Databasedotcom
  module Rails
    module Controller
      module ClassMethods
        def dbdc_client
          unless @dbdc_client
            username = ENV['SALESFORCE_USERNAME']
            password = ENV["SALESFORCE_PASSWORD"]
            @dbdc_client = Databasedotcom::Client.new(
              client_id: ENV['SALESFORCE_CLIENT_ID'], 
              client_secret: ENV['SALESFORCE_CLIENT_SECRET'],
              verify_mode: 0,
              debugging: nil, 
              version: ENV["SALESFORCE_VERSION"],
              host: ENV["SALESFORCE_HOST"]
            )
            @dbdc_client.authenticate(:username => username, :password => password)
          end

          @dbdc_client
        end
        
        def dbdc_client=(client)
          @dbdc_client = client
        end

        def sobject_types
          unless @sobject_types
            @sobject_types = dbdc_client.list_sobjects
          end

          @sobject_types
        end

        def const_missing(sym)
          if sobject_types.include?(sym.to_s)
            dbdc_client.materialize(sym.to_s)
          else
            super
          end
        end
      end
      
      module InstanceMethods
        def dbdc_client
          self.class.dbdc_client
        end

        def sobject_types
          self.class.sobject_types
        end
      end
      
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.send(:extend, ClassMethods)
      end
    end
  end
end
