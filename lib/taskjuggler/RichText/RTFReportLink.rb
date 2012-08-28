#!/usr/bin/env ruby -w
# encoding: UTF-8
#
# = RTFReportLink.rb -- The TaskJuggler III Project Management Software
#
# Copyright (c) 2006, 2007, 2008, 2009, 2010, 2011, 2012
#               by Chris Schlaeger <chris@linux.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of version 2 of the GNU General Public License as
# published by the Free Software Foundation.
#

require 'taskjuggler/RichText/RTFWithQuerySupport'
require 'taskjuggler/XMLElement'
require 'taskjuggler/URLParameter'
require 'taskjuggler/SimpleQueryExpander'
require 'taskjuggler/LogicalExpression'

class TaskJuggler

  # This class is a specialized RichTextFunctionHandler that generates a link
  # to another report. It's not available on all output formats.
  class RTFReportLink < RTFWithQuerySupport

    def initialize(project, sourceFileInfo = nil)
      @project = project
      super('reportlink', sourceFileInfo)
      @blockFunction = false
      @blockMode = false
    end

    # Not supported for this function
    def to_s(args)
      ''
    end

    # Return a HTML tree for the report.
    def to_html(args)
      unless @query
        raise "No Query has been registered for this RichText yet!"
      end

      if args.nil? || (id = args['id']).nil?
        error('rtp_report_id',
              "Argument 'id' missing to specify the report to be used.")
        return nil
      end
      unless (report = @project.report(id))
        error('rtp_report_unknown_id', "Unknown report #{id}")
        return nil
      end

      # The URL for interactive reports is different than for static reports.
      if report.interactive?
        # The project and report ID must be provided as query.
        url = "taskjuggler?project=#{@project['projectid']};" +
              "report=#{report.fullId}"

        if args['attributes']
          qEx = SimpleQueryExpander.new(args['attributes'], @query,
                                        @sourceFileInfo)
          url += ";attributes=" + URLParameter.encode(qEx.expand)
        end
      else
        # The report name just gets a '.html' extension.
        url = report.name + ".html"

        if args['rowid']
          qEx = SimpleQueryExpander.new(args['rowid'], @query,
                                        @sourceFileInfo)

          url += "#" + qEx.expand
        end
      end
      a = XMLElement.new('a', 'href'=> url)
      if args['label']
        qEx = SimpleQueryExpander.new(args['label'], @query,
                                      @sourceFileInfo)
        rti = RichText.new(qEx.expand).generateIntermediateFormat
        rti.blockMode = @blockMode
        a << rti.to_html
      else
        label = report.name
        a << XMLText.new(label)
      end
      a
    end

    # Not supported for this function.
    def to_tagged(args)
      nil
    end

  end

end


