$(function() {
  if($('#quicksearch').searchField !== undefined){
    $("#quicksearch").searchField();
  }

  if($('.preview_link').fancybox !== undefined){
    $('.preview_link').fancybox();
  }

  // show/hide answers to common questions
  $('.faqs dt a').live('click', function(e) {
    e.preventDefault();
    $(this).toggleClass('open');
    $(this).parent().next('dd').slideToggle();
  });

  // sidebar quicknav
  $('#quicknav').change(function() {
    window.location = $(this).val();
  });

  // sidebar navigation
  $('#nav').accordion({
    autoHeight: false,
    active: activeNav,
    header: 'a.category'
  });

  // featured area slideshow
  if ($('#cycle').length > 0) {
    $('#cycle').cycle({
      fx: 'fade',
      pager: '#controls',
      pagerAnchorBuilder: function(index, element) {
        return '<li><a href="#">&bull;</a></li>';
      },
      pause: 1,
      timeout: 10000
    });
  };

  // multi-language code samples
  if ($('.multiplecode').length > 0) {
    var languages = [];
    var preference = 'ruby';

    if (window.location.search != '') {
      var qs = window.location.search.slice(1).split('&');
      $.each(qs, function(index, element) {
        var pieces = element.split('=');
        if (pieces[0] == 'lang') {
          preference = pieces[1];
        }
      });
    };

    $('.multiplecode').each(function() {
      // collapse secondary samples
      $(this).find('pre[lang!='+preference+']').hide();

      // collect languages
      var links = $(this).find('pre').map(function() {
        var lang = $(this).attr('lang');
        languages.push(lang);
        return "<li><a href='?lang=" + lang + "' lang='" + lang + "'>" + lang + "</a></li>";
      });

      // create bar
      $(this).prepend('<div class="languagebar"><ul>'+$.makeArray(links).join('')+'</ul></div>');

      $(this).find('.languagebar a[lang='+preference+']').addClass('current');
      $(this).find('pre').css({
        '-moz-border-radius': '0 0 3px 3px',
        '-webkit-border-radius': '0 0 3px 3px'
      });

      // create global preference bar
      // $('#article article #admin-tabs').prepend('<select id="language-links"></select>');
      // $.each(languages, function(index, element) {
      //   var selected = (element == preference ? ' selected="selected"' : '');
      //   $('#language-links').append('<option value="' + element + '" '+ selected +'>' + element + '</option>');
      // });
    });

    $('#language-links').change(function() {
      var current = window.location.href;
      var destination = current;
      if (current.match(/lang=/)) {
        destination = destination.replace('lang='+preference, 'lang='+$(this).val());
      } else {
        if (destination.match(/\?/)) {
          destination = destination + '&lang='+$(this).val();
        } else {
          destination = destination + '?lang='+$(this).val();
        }
      }
      window.location = destination;
    });
  };

  $('.languagebar a').live('click', function(e) {
    e.preventDefault();
    var lang = $(this).text();
    var $container = $(this).closest('.multiplecode');
    $container.find('.languagebar a').removeClass('current');
    $(this).addClass('current');
    $container.find('pre[lang!="'+lang+'"]').hide();
    $container.find('pre[lang="'+lang+'"]').show();
  });

  $('#article-results a').live('click', function(e) {
    $.post('http://node-ben.heroku.com/track?callback=?', {query: query, clicked: $(this).text()});
  });

  // ajax search
  if ($('p.loading').length > 0) {
    var page = jQuery.deparam.querystring(window.location.href, true).page
    $.getJSON('/articles.json', {q: query, page: page}, function(data) {
      $article_results = $('#article-results ul');
      if (data.message){
        $article_results.prepend('<p>' + data.message + '</p>');
      }
      $.each(data.devcenter, function(index, result) {
        $article_results.append('<li><a href="'+  result.url +'">' + result.title + '</a></li>')
      });
      $('#article-results .loading').hide();
      $('#article-results .results').show();
      if (data.devcenter.length > 0) {
        if (data.next_page){
          var next_page_url = jQuery.param.querystring(window.location.href, { page : data.next_page })
          $('#pagination a#next').text("More results »").attr('href', next_page_url)
        }
        if (data.prev_page){
          var prev_page_url = jQuery.param.querystring(window.location.href, { page : data.prev_page })
          $('#pagination a#previous').text("« Previous results").attr('href', prev_page_url)
        }
      }
    });
  }
});