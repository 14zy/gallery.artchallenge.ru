require "json"


## Берем всю инфу по языку из CouchDB
lang = "en";
# lang = JSON.parse `curl -X GET http://178.62.133.139:5994/lang/ru`
#print lang["head"]["title"]


for n in 1..118

  ## Берем всю инфу по художнику из CouchDB
  painter = JSON.parse `curl -X GET http://178.62.133.139:5994/painters/#{n}`
  # print painter["name"]

  description =  painter["bio"][lang].sub("<p>","")[0..150].gsub(/\s\w+\s*$/, '...')

  if painter["bio"]['en'] == ""
    painter["bio"]['en'] = "<p>We beg your pardon, but temporary this painter's biography is not available</p><p>If you know the good source, please contact us: <a href='mailto:report@artchallenge.ru'>report@artchallenge.ru</a>.</p>"
  end

  # Генерим страницу
  html =  %{
    <!doctype html>
    <html lang="en">
      <head>
        <meta charset="utf-8">
        <meta name="description" content="#{ description }">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>#{ painter["name"] }, #{ painter["nationality"].join(', ') } #{ painter["genre"].join(', ') } painter – Art Challenge</title>
        <link rel="stylesheet" href="../css/bootstrap.min.css">
        <link rel="stylesheet" href="../css/jquery.fancybox.css">
        <link rel="stylesheet" href="../css/main.css">
        <link rel="stylesheet" href="../css/responsive.css">
        <link rel="stylesheet" href="../css/animate.min.css">
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.4.0/css/font-awesome.min.css">

        <meta name="apple-itunes-app" content="app-id=1088982103">
        <link rel="alternate" hreflang="ru" href="http://gallery.artchallenge.ru/ru/#{ painter["id"] }.html"/>
        <link rel="alternate" hreflang="en" href="http://gallery.artchallenge.ru/en/#{ painter["id"] }.html"/>

      </head>
      <body>
        <!-- Yandex.Metrika counter -->
        <script type="text/javascript">
            (function (d, w, c) {
                (w[c] = w[c] || []).push(function() {
                    try {
                        w.yaCounter24594722 = new Ya.Metrika({
                            id:24594722,
                            clickmap:true,
                            trackLinks:true,
                            accurateTrackBounce:true,
                            webvisor:true
                        });
                    } catch(e) { }
                });

                var n = d.getElementsByTagName("script")[0],
                    s = d.createElement("script"),
                    f = function () { n.parentNode.insertBefore(s, n); };
                s.type = "text/javascript";
                s.async = true;
                s.src = "https://mc.yandex.ru/metrika/watch.js";

                if (w.opera == "[object Opera]") {
                    d.addEventListener("DOMContentLoaded", f, false);
                } else { f(); }
            })(document, window, "yandex_metrika_callbacks");
        </script>
        <noscript><div><img src="https://mc.yandex.ru/watch/24594722" style="position:absolute; left:-9999px;" alt="" /></div></noscript>
        <!-- /Yandex.Metrika counter -->
        <section class="banner" role="banner">
          <header id="header">
            <div class="header-content clearfix">
              <a class="logo" href="http://gallery.artchallenge.ru/#{lang}/#{ painter["id"] }.html">#{ painter["name"] }</a>
              <nav class="navigation" role="navigation">
                <ul class="primary-nav">
                  <li>
                    <a href="http://artchallenge.ru">Back to Game</a>
                  </li>
                  <li>
                    <a href="http://gallery.artchallenge.ru/">Browse Painters</a>
                  </li>
                  <li>
                    <a href="http://artchallenge.ru/#introduction">Donate</a>
                  </li>
                </ul>
              </nav>
              <a href="#" class="nav-toggle">Menu<span></span>
              </a>
            </div>
          </header>
        </section>
        <section id="introduction" class="section introduction" style='padding-bottom:0'>
          <div class="container">
            <div class="row">
              <div class="col-md-4 col-sm-6">
                <div class="intro-content">
                  <img style='width:100%' src='../images/painters/#{ painter["id"] }.jpg'>
                </div>
              </div>
              <div class="col-md-5 col-sm-6">
                <div class="intro-content">
                  #{ painter["bio"][lang] }
                </div>
              </div>
              <div class="col-md-3 col-sm-6">
                <div class="intro-content">
                <h4>Nationality</h4>
                #{ painter["nationality"].join(', ') }
                <h4>Genres</h4>
                #{ painter["genre"].join(', ') }
                <h4>Years</h4>
                #{ painter["years"] }
                <h4>Wikipedia</h4>
                <a target='_blank' href='#{ painter["link"]['wikipedia'][lang] }'>Open page</a>
                </div>
              </div>
            </div>
          </div>
        </section>
        <section id="works" class="works section no-padding">
          <div class="container-fluid">
          <div class='text-center'><br><br><h3>#{ painter["name"] } paintings:</h3><br><br></div>
            <div class="row no-gutter">
  }


  gallery = ""
  for i in 1..painter["paintings"].count
      gallery = gallery + %{
        <div class="col-lg-2 col-md-4 col-sm-4 work">
          <a rel='gallery-examples' href="http://artchallenge.me/painters/#{ painter["id"] }/#{i}.jpg" class="work-box">
            <img class='lazy' data-src="http://artchallenge.me/painters/#{ painter["id"] }/#{i}.jpg" alt="#{ painter["name"] } painting">
            <div class="overlay">
              <div class="overlay-caption">
                <p>
                  <i class="fa fa-search-plus fa-2x"></i>
                </p>
              </div>
            </div>
          </a>
        </div>
      }
  end


  html = html + gallery + %{
            </div>
          </div>
        </section>
        <footer id="contact" class="footer">
          <div class="container">
            <div class="col-md-4">
              <h4>Contact</h4>
              <p>
                <a href='http://facebook.com/just14zy'>Ruben Babaev</a> and <a href='http://www.facebook.com/plotkina.anna'>Anna Plotkina</a>
                <br>
                Email:
                <a href="mailto:info@artchallenge.ru">
                  info@artchallenge.ru
                </a>
              </p>
            </div>
            <div class="col-md-3">
              <h4>Social presense</h4>
              <ul class="footer-share">
                <li>
                  <a href="http://facebook.com/artchallenge.ru/">
                    <i class="fa fa-facebook"></i>
                  </a>
                </li>
                <li>
                  <a href="http://vk.com/art.challenge">
                    <i class="fa fa-vk"></i>
                  </a>
                </li>
                <li>
                  <a href="http://twitter.com/artchallenge_ru">
                    <i class="fa fa-twitter"></i>
                  </a>
                </li>
              </ul>
            </div>
            <div class="col-md-5">
              <p>© 2013-2016 All rights reserved.<br>
                Made with
                <i class="fa fa-heart pulse"></i>
                in
                <a href="#">Rostov-on-Don</a>
              </p>
            </div>
          </div>
        </footer>
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
        <script src="../js/bootstrap.min.js"></script>
        <script src="../js/jquery.fancybox.pack.js"></script>
        <script src="../js/main.js"></script>
        <script src="../js/jquery.lazy.min.js"></script>

        <script>$(function() {$('.lazy').Lazy();});</script>
      </body>
    </html>
  }




  File.open("../"+lang+"/"+painter["_id"] +".html", 'w+') do |file|
      file.write html
  end

end
