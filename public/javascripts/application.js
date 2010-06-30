$(function() {
  $('input.default').focus();
  $('.number_suggestion').click(function() {
    $(this).parents('li').children('input[type=text]').val(this.rel);
    return false;
  });
  $('input.datepicker').datepicker({
    showOn:'button',
    buttonImage: '/images/icons/silk/calendar_select_day.png',
    buttonImageOnly: true
  });
  $('#from').change(function() {
    $('#notifier').show();
    $.get("/transactions/created",
      { from: this.value,
        until: $('#until').val(),
        category: $('#category').val(),
        warehouse: $('#warehouse').val() },
      function() { $('#notifier').hide(); },
      'script');
  });
  $('#until').change(function() {
    $('#notifier').show();
    $.get("/transactions/created",
      { from: $('#from').val(),
        until: this.value,
        category: $('#category').val(),
        warehouse: $('#warehouse').val() },
      function() { $('#notifier').hide(); }, 'script');
  });
  $('#category').change(function() {
    $('#notifier').show();
    $.get("/transactions/created",
      { from: $('#from').val(),
        until: $('#until').val(),
        category: this.value,
        warehouse: $('#warehouse').val() },
      function() { $('#notifier').hide(); }, 'script');
  });
  $('#warehouse').change(function() {
    $('#notifier').show();
    $.get("/transactions/created",
      { from: $('#from').val(),
        until: $('#until').val(),
        category: $('#category').val(),
        warehouse: this.value },
      function() { $('#notifier').hide(); }, 'script');
  });
  $('#all').click(function() {
    if(this.checked) {
      $('.transaction_type:visible').attr('checked', 'checked');
    } else {
      $('.transaction_type').removeAttr('checked');
    }
  });
  if($('table#enhanced').length) {
    $('table#enhanced').dataTable({"bJQueryUI": true});
  }
  if($('.item_chooser').length) {
    $('.item_chooser').autocomplete(items, {
      formatItem: function(row, i) { return row.item.name; },
      autoFill: true,
      mustMatch: true }
    )
    .result(function(event, data) {
      var input = $(this);
      if(data) {
        // $.get('/items/'+data.item.id+'/customer_prices',
        // input.next('input[type=hidden]').val(data.item.id);
        // input.parent().next().html(data.item.name);
        // input.parent().next().next().children()[0].focus();
        event.stopImmediatePropagation();
      }
      // else input.next('input[type=hidden]').val('');
    });
  }
  $('#check_master').click(function() {
    if(this.checked) {
      $('.check_slave').attr('checked', 'checked');
    } else {
      $('.check_slave').removeAttr('checked');
    }
  });
});

$('.plu_input').live('click', function() {
  var input_id = $(this).prevAll('input[type=text]').attr("id");
  $('body').data('input_id', '#' + input_id);
  Boxy.load(this.href, {
    //modal: true,
    draggable: true,
    unloadOnHide: true,
    title: "Item Lookup",
    closeText: "<img src='/images/icons/cross.png' alt='close'/>",
    afterShow: function() {
      $('#keyword').focus();
    }
  });
  return false;
});

$("form#search").live('submit', function() {
  $(this).find('button[type=submit]')
  .after("<span id='progress' style='font-style:italic;color:green;padding-left:5px;'>searching...</span>");
  $.ajax({ url: this.action,
    type: this.method,
    data: $(this).serialize(),
    success: function(response, status) {
      $('#progress').remove();
      $('#searchresult').html(response)
      $('.searchresults tr:nth-child(2) td ul li:first-child a').focus();
      $('.plu_code_handle').bind('click', function() {
        if($('body').data('input_id')) {
          $($('body').data('input_id')).val(this.title).search().parent('td').next().next().children()[0].focus();
          Boxy.get(this).hideAndUnload();
        } else if($('body').data('type') == 'customer_prices') {
          $('body').data('item_id', $(this).next().value);
          //console.log($('body').data('item_id'));
          Boxy.get(this).hideAndUnload();
        }
        return false;
      });
    }
  });
  return false;
});

$('#sidemenu li a.revealer').click(function() {
  $(this).next('ul').toggle();
  return false;
});

function boxy_ajaxify(formwrapper) {
  var form = formwrapper;
  var button = form.find("button[type=submit]");
  button.replaceWith("<p><img src='/images/ui-anim.basic.16x16.gif' alt=''/> <span>Saving... please wait</span></p>");
  $.ajax({url: this.action,
    data: $(this).serialize(),
    type: 'post',
    success: function(response, status) {
      if(response.status == 'validation error') {
        form.replaceWith(response.form);
      } else {
        window.location = response.location
      }
    }
  });
}

$('#add_entries').live('click', function(e) {
  var entries_count = $('#transaction_entries tr').length - 1; // 1 is the table header, we're only intersted in rows with input fields in it
  $('#transaction_entries').append(entry_row(entries_count));
  return false;
});

$('input.entries_quantity, input.entries_value').live('keypress', function(e) {
  if(e.keyCode == 13 && this.value != '') {
    $('#add_entries').click();
    $('#transaction_entries tbody tr:last td:first').children()[0].focus();
    set_autocomplete();
    return false;
  }
});

function entry_row(count) {
  var idx = count;
  var html = "<tr><td class=\"td_20\">" +
    "<input type=\"text\" name=\""+model+"[entries_attributes]["+idx+"][plu_code]\" id=\""+model+"_entries_attributes_"+idx+"_plu_code\" class=\"plu_code ac_input\" autocomplete=\"off\">" +
    "<input type=\"hidden\" name=\""+model+"[entries_attributes]["+idx+"][plu_id]\" id=\""+model+"_entries_attributes_"+idx+"_plu_id\" value=\"\">" +
    "<a class=\"plu_input\" href=\"/items/lookup.js\"><img src=\"/images/icons/silk/magnifier.png\" alt=\"Magnifier\"></a></td> " +
    "<td class=\"td_50\"></td> <td class=\"actions td_10\">" +
    "<input type=\"text\" size=\"10\" name=\""+model+"[entries_attributes]["+idx+"][quantity]\" id=\""+model+"_entries_attributes_"+idx+"_quantity\" class=\"numbers entries_quantity\">" +
    "<input type=\"hidden\" name=\""+model+"[entries_attributes]["+idx+"][item_id]\" id=\""+model+"_entries_attributes_"+idx+"_item_id\"></td>"; 
  if(window.with_value == true) {
    html += "<td class=\"actions td_20\"><input type=\"text\" size=\"30\" name=\""+model+"[entries_attributes]["+idx+"][value]\" id=\""+model+"_entries_attributes_"+idx+"_value\" class=\"numbers entries_value\"></td>"; 
  }
  html += "</tr>";
  return html;
}

function set_autocomplete() {
  $('.plu_code').autocomplete(plu, {
    formatItem: function(row, i) { return row.plu.code; },
    autoFill: true,
    mustMatch: true }
  )
  .result(function(event, data) {
    var input = $(this);
    if(data) {
      input.next('input[type=hidden]').val(data.plu.id);
      input.parent().next().html(data.plu.item_name_with_code);
      input.parent().next().next().children()[0].focus();
      event.stopImmediatePropagation();
    }
    // else input.next('input[type=hidden]').val('');
  });
}
$('#add_item').live('click', function() {
  $('body').data('type', 'customer_prices');
  Boxy.load(this.href, {
    //modal: true,
    draggable: true,
    unloadOnHide: true,
    title: "Item Lookup",
    closeText: "<img src='/images/icons/cross.png' alt='close'/>",
    afterShow: function() {
      $('#keyword').focus();
    },
    beforeUnload: function() {
      var item_id = $('body').data('item_id');
      window.location = window.location.toString().replace(/\/+$/,'') + '/new?item=' + item_id;
    }
  });
  return false;
});
