$(function() {
  setupPage();
  setupIndex();
  setupBrowser();
})

function setupPage() {
  setPageHeight();
  $(window).resize(function() {
    setPageHeight();
  });
}

function setPageHeight() {
  height = $('#page').height() - 240
  $("#browser").height(height);
  $("#browser .contents").height(height - $("#browser .header").height() - 38);
  $("#index").height(height);
}

function setupIndex() {
  $('#index a').live('click', function() {
    $('#index a').removeClass('selected');
    $(this).addClass('selected');
    id = this.href.match(/\d+/)[0];
    $('#browser .contents').scrollTo($('#' + id));
    return false;
  });
}

function setupBrowser() {
  setBrowserWidth();
  $(window).resize(function() {
    setBrowserWidth();
  });
}

function setBrowserWidth() {
  $("#browser").width($('#page_contents').width() - $('#index').width() - 30);
}
