require 'fileutils'
require 'chef/mixin/shell_out'

class Chef
  class Provider
    class Solr4Core < Chef::Provider
      include Chef::Mixin::ShellOut

      def load_current_resource
        @current_resource ||= Chef::Resource::Solr4Core.new(new_resource.name)
        @current_resource.solr_path(new_resource.solr_path)
        @current_resource
      end

      def action_create
        copy_collection1 unless core_cloned?
        define_core_properties
        ensure_permissions
      end

      def action_remove
      end

      protected

      def copy_collection1
        shell_out! "cp -R #{@current_resource.solr_path}/collection1 #{core_path}"
        Chef::Log.info "copied collection1 to #{@current_resource.name}"
      end

      def define_core_properties
        Chef::Log.info "renaming collection1 to #{@current_resource.name} in core.properties"
        shell_out! "sed -i s/collection1/#{@current_resource.name}/g #{core_path}/core.properties"
      end

      def ensure_permissions
        shell_out! "chown -R #{node['solr']['solr_user']} #{core_path}"
        Chef::Log.info "ensured #{node['solr']['solr_user']} owns #{core_path}"
      end

      def core_cloned?
        ::File.exists?(core_path)
      end

      def core_path
        @current_resource.solr_path + "/" + @current_resource.name
      end
    end
  end
end
