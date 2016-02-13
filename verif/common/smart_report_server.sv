// ----------------------------------------------------------------------------
// Tecon MT
// ----------------------------------------------------------------------------
// FILE NAME      : smart_report_server.sv
// PROJECT        :
// AUTHOR         : Grigoriy Zhiharev
// AUTHOR'S EMAIL :
// ----------------------------------------------------------------------------
// DESCRIPTION    : uvm-1.2
// ----------------------------------------------------------------------------

`ifndef INC_SMART_REPORT_SERVER
`define INC_SMART_REPORT_SERVER

class smart_report_server extends uvm_default_report_server;

   string filename_cache[string];
   string hier_cache[string];

   int unsigned file_name_width = 20;
   int unsigned hier_width      = 15;

  virtual function string compose_report_message(uvm_report_message report_message, string  report_object_name = "");
    string sev_string;
    uvm_severity l_severity;
    uvm_verbosity l_verbosity;
    string filename_line_string;
    string time_str;
    string line_str;
    string context_str;
    string verbosity_str;
    string terminator_str;
    string msg_body_str;
    uvm_report_message_element_container el_container;
    string prefix;
    uvm_report_handler l_report_handler;

    // Custom
    string hier_str;

    l_severity = report_message.get_severity();
    sev_string = l_severity.name();

    // Format filename & line-number
    if (report_message.get_filename() != "") begin
      line_str.itoa(report_message.get_line());
      filename_line_string = format_filename(report_message.get_filename(), line_str);
    end

    // Make definable in terms of units.
    $swrite(time_str, " { %0t } ", $time);

    // Format hier
    if (report_object_name == "") begin
      l_report_handler = report_message.get_report_handler();
      report_object_name = l_report_handler.get_full_name();
    end
    if (report_message.get_context() != "") begin
      context_str = {"@@", report_message.get_context()};
    end
    hier_str = {report_object_name, context_str};
    hier_str = format_hier(hier_str);

    if (show_verbosity) begin
      if ($cast(l_verbosity, report_message.get_verbosity()))
        verbosity_str = l_verbosity.name();
      else
        verbosity_str.itoa(report_message.get_verbosity());
      verbosity_str = {"(", verbosity_str, ")"};
    end

    if (show_terminator)
      terminator_str = {" -",sev_string};

    el_container = report_message.get_element_container();
    if (el_container.size() == 0)
      msg_body_str = report_message.get_message();
    else begin
      prefix = uvm_default_printer.knobs.prefix;
      uvm_default_printer.knobs.prefix = " +";
      msg_body_str = {report_message.get_message(), "\n", el_container.sprint()};
      uvm_default_printer.knobs.prefix = prefix;
    end

    //compose_report_message = {sev_string, verbosity_str, " ", filename_line_string, "@ ",
    //  time_str, ": ", report_object_name, context_str,
    //  " [", report_message.get_id(), "] ", msg_body_str, terminator_str};

    compose_report_message = {sev_string, verbosity_str, " [", filename_line_string, "]",
      time_str, hier_str, " [", report_message.get_id(), "] ",
      msg_body_str, terminator_str};

  endfunction

  function string format_filename(string filename, string line);
    int last_slash;
    int flen;
    if(filename.len > 0) begin
      last_slash = filename.len() - 1;
      if(file_name_width > 0) begin
        if(filename_cache.exists(filename))
          format_filename = filename_cache[filename];
        else begin
          while(filename[last_slash] != "/" && last_slash != 0)
            last_slash--;
          if(filename[last_slash] == "/")
            format_filename =  filename.substr(last_slash+1, filename.len()-1);
          else
            format_filename = filename;
          flen = format_filename.len();
          if(flen > file_name_width)
            format_filename = format_filename.substr((flen - file_name_width), flen-1);
          else
            format_filename = {{(file_name_width-flen){" "}}, format_filename};
          filename_cache[filename] = format_filename;
        end
      end else
        format_filename = "";
    end
    format_filename = {format_filename, "(", line, ") "};
  endfunction

  function string format_hier(string str);
    int hier_len;
    hier_len = str.len();
    if(hier_width > 0) begin
      if(hier_cache.exists(str))
        format_hier = hier_cache[str];
      else begin
        if(hier_len > 13 && str.substr(0,12) == "uvm_test_top.") begin
          str = str.substr(13, hier_len - 1);
          hier_len -= 13;
        end
        if(hier_len < hier_width)
          format_hier = {str, {(hier_width - hier_len){" "}}};
        else if(hier_len > hier_width)
          format_hier = str.substr(hier_len - hier_width, hier_len - 1);
        else
          format_hier = str;
       format_hier = {"[", format_hier, "]"};
        hier_cache[str] = format_hier;
      end
    end else
      format_hier = "";
  endfunction

endclass

`endif

