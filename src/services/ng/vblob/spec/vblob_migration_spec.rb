# Copyright (c) 2009-2011 VMware, Inc.

$:.unshift(File.dirname(__FILE__))

require "spec_helper"

describe "vblob_node migration test" do

  before :all do
    EM.run do
      @opts = get_node_config()
      @logger = @opts[:logger]
      @node = Node.new(@opts)
      EM.add_timer(1) { EM.stop }
    end
    @response = @node.provision("free")
    @provisioned_service = @node.get_instance(@response['name'])
    @bind_response = @node.bind(@response['name'], 'rw')
  end

  after :all do
    @node.unprovision(@response['name'], []) unless @node.get_instance(@response['name']).nil?
    @node.shutdown if @node
    FileUtils.rm_rf('/tmp/vblob')
  end

  it "should be able to disable the instance" do
    @node.disable_instance(@response, {'' => {'credentials' => ''}}).should be_true
    is_port_open?(@provisioned_service.ip, @provisioned_service.service_port).should be_false
    @node.get_healthz(@provisioned_service).should == "fail"
    @node.is_service_started(@provisioned_service).should == false
  end

  it "should be able to enable the instance after diabling it" do
    @node.disable_instance(@response, {'' => {'credentials' => ''}}).should be_true
    @node.enable_instance(@response, {'' => {'credentials' => ''}}).should be_true
    @provisioned_service = @node.get_instance(@response['name'])
    is_port_open?(@provisioned_service.ip, @provisioned_service.service_port).should be_true
  end
end
