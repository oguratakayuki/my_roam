## -*- coding: utf-8 -*-
require '../lib/view/elements.rb'
require 'curses'

describe "Elements" do
  #describe "InputElements" do
  #  describe "initialize" do
  #    let(:element_id) { 1 }
  #    let(:h) { 10 }
  #    let(:w) { 20 }
  #    let(:x) { 30 }
  #    let(:y) { 40 }
  #    let(:title) { 'hoge' }
  #    let(:attributes) { {:aaa => 'bbb', :object_name => :piyo} }
  #    before { @ie = InputElement.new(element_id, h, w, x, y, title, attributes) }
  #    subject { @ie }
  #    its(:element_key) { should == :piyo }
  #  end
  #end

  describe "RadioElements" do
    describe "initialize" do
      before do
        forms_setting = YAML.load_file('./settings.yml')[:forms]
        id,h,w,x,y,title,attributes = forms_setting[:select_job][:elements][0].values_at(:id, :h, :w, :x, :y, :title, :attributes)
        @radio_button = RadioElement.new(id,h,w,x,y, title, attributes)
      end
      subject { @radio_button }
      it "正しくrorationされること" do
        @radio_button.selected_button.should == 1
        @radio_button.key_event(Curses::Key::RIGHT)
        @radio_button.selected_button.should == 2
        @radio_button.key_event(Curses::Key::RIGHT)
        @radio_button.selected_button.should == 3
        @radio_button.key_event(Curses::Key::RIGHT)
        @radio_button.selected_button.should == 1
        @radio_button.key_event(Curses::Key::LEFT)
        @radio_button.selected_button.should == 3
        @radio_button.key.should == :job
        @radio_button.value.should == 3
      end







      #let(:element_id) { 1 }
      #let(:h) { 10 }
      #let(:w) { 20 }
      #let(:x) { 30 }
      #let(:y) { 40 }
      #let(:title) { 'hoge' }
      #let(:attributes) { {:aaa => 'bbb', :object_name => :piyo} }
      #before { @ie = InputElement.new(element_id, h, w, x, y, title, attributes) }
      #subject { @ie }
      #its(:element_key) { should == :piyo }
    end
  end



end
