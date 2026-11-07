// Page shells retain the existing DOM, styles and script loading order.
import 'dart:convert';
import 'package:intl/intl.dart';

String escape(Object? value) =>
    const HtmlEscape().convert(value?.toString() ?? '');
String date(Object? value) =>
    DateFormat('MMMM dd, yyyy').format(DateTime.parse('$value'));

String homeMarkup(Map<String, dynamic> d) =>
    '''<!doctype html>

<html lang="en" data-bs-theme="dark">
<head>
  <meta charset="utf-8">
  <title>${escape(d['title'])}</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="description" content="${escape(d['tagline'])}">

  <link rel="apple-touch-icon" sizes="180x180" href="/images/favicon/apple-touch-icon.png">
  <link rel="icon" type="image/png" sizes="32x32" href="/images/favicon/favicon-32x32.png">
  <link rel="icon" type="image/png" sizes="16x16" href="/images/favicon/favicon-16x16.png">
  <link rel="manifest" href="/images/favicon/site.webmanifest">
  <link rel="mask-icon" href="/images/favicon/safari-pinned-tab.svg" color="#f8217e">
  <link rel="shortcut icon" href="/images/favicon/favicon.ico">
  <meta name="theme-color" content="#0D0912">

  <link rel="canonical" href="https://getflocked.dev${escape(d['url'])}">

  <!-- Open Graph -->
  <meta property="og:title" content="${escape(d['title'])}" />
  <meta property="og:description" content="${escape(d['tagline'])}" />
  <meta property="og:url" content="https://getflocked.dev${escape(d['url'])}" />
  ${socialMarkup(d)}

  <!-- X/Twitter -->
  <meta name="twitter:card" content="summary_large_image" />
  <meta name="twitter:site" content="@suprdeclarative" />
  <meta name="twitter:title" content="${escape(d['title'])}" />
  <meta name="twitter:description" content="${escape(d['tagline'])}" />

  <link href="/styles/styles.css" rel="stylesheet">
  <link href="/styles/home.css" rel="stylesheet">
  <link href="/styles/hero.css" rel="stylesheet">
  <link href="/styles/features.css" rel="stylesheet">

  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:ital,opsz,wght@0,14..32,100..900;1,14..32,100..900&family=Fira+Mono:wght@400;500;700&display=swap" rel="stylesheet">
  <link href="/styles/navigation.css" rel="stylesheet">

</head>

<body class="home">
  <main class="site-home">
    <site-homehero></site-homehero>
    <site-homefeatures></site-homefeatures>
  </main>

  <site-footer></site-footer>
  <script src="/scripts/hero/commit-content.js"></script>
  <script src="/scripts/hero/visibility.js"></script>
  <script src="/scripts/hero/plume.js"></script>
  <script src="/scripts/hero/edge-glow.js"></script>
  <script src="/scripts/hero/flock-commits.js"></script>
  <script src="/scripts/hero/flutter-commits.js"></script>
  <script src="/scripts/hero/hero-layout.js"></script>
  <script src="/scripts/features.js"></script>
</body>
</html>
''';

String blogMarkup(Map<String, dynamic> d) =>
    '''<!doctype html>

<html lang="en" data-bs-theme="dark">
<head>
  <meta charset="utf-8">
  <title>${escape(d['title'])}</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="description" content="${escape(d['description'])}">

  <link rel="apple-touch-icon" sizes="180x180" href="/images/favicon/apple-touch-icon.png">
  <link rel="icon" type="image/png" sizes="32x32" href="/images/favicon/favicon-32x32.png">
  <link rel="icon" type="image/png" sizes="16x16" href="/images/favicon/favicon-16x16.png">
  <link rel="manifest" href="/images/favicon/site.webmanifest">
  <link rel="mask-icon" href="/images/favicon/safari-pinned-tab.svg" color="#f8217e">
  <link rel="shortcut icon" href="/images/favicon/favicon.ico">
  <meta name="msapplication-TileColor" content="#0d0912">
  <meta name="msapplication-config" content="/images/favicon/browserconfig.xml">
  <meta name="theme-color" content="#0d0912">

  <link rel="canonical" href="https://getflocked.dev${escape(d['url'])}">

  <!-- Open Graph -->
  <meta property="og:title" content="${escape(d['title'])}" />
  <meta property="og:description" content="${escape(d['description'])}" />
  <meta property="og:url" content="https://getflocked.dev${escape(d['url'])}" />
  ${socialMarkup(d)}

  <!-- X/Twitter -->
  <meta name="twitter:card" content="summary_large_image" />
  <meta name="twitter:site" content="@suprdeclarative" />
  <meta name="twitter:title" content="${escape(d['title'])}" />
  <meta name="twitter:description" content="${escape(d['description'])}" />

  <link href="/styles/styles.css" rel="stylesheet">
  <link href="/styles/blog-directory.css" rel="stylesheet">

  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:ital,opsz,wght@0,14..32,100..900;1,14..32,100..900&display=swap" rel="stylesheet">
  <link href="/styles/navigation.css" rel="stylesheet">
</head>

<body class="themed blog-page">
<site-navbar></site-navbar>
<section class="blog-hero" aria-hidden="true">
  <img src="/images/blog/fleek-at-desk-typing.webp" width="1920" height="634" alt="" fetchpriority="high">
</section>

<main>
  <h1>BLOG</h1>
  <p>The latest news about Flock and Nest.</p>
  <section id="posts">
    <ol class="post-list">
      <site-posts></site-posts>
    </ol>
  </section>
</main>

<site-footer></site-footer>
</body>
</html>
''';

String guideMarkup(Map<String, dynamic> d) =>
    '''<!doctype html>

<html lang="en" data-bs-theme="dark">
<head>
  <meta charset="utf-8">
  <title>${escape(d['title'])}</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="description" content="${escape(d['description'])}">

  <link rel="apple-touch-icon" sizes="180x180" href="/images/favicon/apple-touch-icon.png">
  <link rel="icon" type="image/png" sizes="32x32" href="/images/favicon/favicon-32x32.png">
  <link rel="icon" type="image/png" sizes="16x16" href="/images/favicon/favicon-16x16.png">
  <link rel="manifest" href="/images/favicon/site.webmanifest">
  <link rel="mask-icon" href="/images/favicon/safari-pinned-tab.svg" color="#f8217e">
  <link rel="shortcut icon" href="/images/favicon/favicon.ico">
  <meta name="theme-color" content="#0d0912">

  <link rel="canonical" href="https://getflocked.dev${escape(d['url'])}">

  <!-- Open Graph -->
  <meta property="og:title" content="${escape(d['title'])}" />
  <meta property="og:description" content="${escape(d['description'])}" />
  <meta property="og:url" content="https://getflocked.dev${escape(d['url'])}" />
  ${socialMarkup(d)}

  <!-- X/Twitter -->
  <meta name="twitter:card" content="summary_large_image" />
  <meta name="twitter:site" content="@suprdeclarative" />
  <meta name="twitter:title" content="${escape(d['title'])}" />
  <meta name="twitter:description" content="${escape(d['description'])}" />

  <link href="/styles/styles.css" rel="stylesheet">
  <link href="/styles/guide.css" rel="stylesheet">

  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:ital,opsz,wght@0,14..32,100..900;1,14..32,100..900&family=Fira+Mono:wght@400;500;700&display=swap" rel="stylesheet">
  <link href="/styles/navigation.css" rel="stylesheet">
  <script src="/scripts/table-of-contents.js" defer></script>
  <script src="/scripts/section-navigation.js" defer></script>
  ${d['code_examples'] == true ? '''
  <link href="/styles/code-examples.css" rel="stylesheet">
  <script src="/scripts/vendor/prism/prism-flock.min.js" defer></script>
  <script src="/scripts/code-copy-controls.js" defer></script>
  ''' : ''}

</head>

<body class="themed guide-page">
<site-navbar></site-navbar>
${d['show_hero'] == true ? '''
<section class="flock-hero" aria-hidden="true">
  <div class="flock-storm" aria-hidden="true">
    <div class="storm-clouds"></div>
    <canvas class="storm-atmosphere"></canvas>
  </div>
  <div class="flock-flight-stage">
    <img class="flight-group flight-dash" src="/images/flock/dash-exhausted.webp" width="600" height="334" alt="" fetchpriority="high">
    <svg class="flight-group flight-fleeks" width="1200" height="600" viewBox="0 0 1200 600" aria-hidden="true">
      <image class="fleek-bird fleek-right" href="/images/flock/fleek-right.webp" x="829" y="14" width="355" height="271" />
      <image class="fleek-bird fleek-left" href="/images/flock/fleek-left-complete.webp" x="-30" y="-52" width="511" height="390" />
      <image class="fleek-bird fleek-leader" href="/images/flock/fleek-leader-complete.webp" x="0" y="30" width="1185" height="570" />
    </svg>
  </div>
</section>
<script src="/scripts/flock-flight.js" defer></script>
<script src="/scripts/flock-storm.js" defer></script>
''' : ''}
<site-sectionnav></site-sectionnav>
<header class="flock-page-heading">
  <site-brand></site-brand>
</header>

<main>

  <div id="contentColumns">
    <div id="sideMenuColumn">
      <nav id="sideMenu">

        <site-sidemenu></site-sidemenu>

      </nav>
    </div>

    <div id="contentColumn">
    <!-- ^ "min-width: 0" - a hack to get <pre> tags to respect width in a flex row: https://stackoverflow.com/questions/32035406/how-to-limit-pre-tag-width-inside-flex-container -->
    <site-content></site-content>
    </div>

    <aside id="pageContentsColumn" aria-label="Page contents"></aside>
  </div>

</main>

<site-footer></site-footer>

</body>
</html>
''';

String nestMarkup(Map<String, dynamic> d) =>
    '''<!doctype html>

<html lang="en" data-bs-theme="dark">
<head>
  <meta charset="utf-8">
  <title>${escape(d['title'])}</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="description" content="${escape(d['description'])}">

  <link rel="apple-touch-icon" sizes="180x180" href="/images/favicon/apple-touch-icon.png">
  <link rel="icon" type="image/png" sizes="32x32" href="/images/favicon/favicon-32x32.png">
  <link rel="icon" type="image/png" sizes="16x16" href="/images/favicon/favicon-16x16.png">
  <link rel="manifest" href="/images/favicon/site.webmanifest">
  <link rel="mask-icon" href="/images/favicon/safari-pinned-tab.svg" color="#f8217e">
  <link rel="shortcut icon" href="/images/favicon/favicon.ico">
  <meta name="theme-color" content="#0d0912">

  <link rel="canonical" href="https://getflocked.dev${escape(d['url'])}">

  <!-- Open Graph -->
  <meta property="og:title" content="${escape(d['title'])}" />
  <meta property="og:description" content="${escape(d['description'])}" />
  <meta property="og:url" content="https://getflocked.dev${escape(d['url'])}" />
  ${socialMarkup(d)}

  <!-- X/Twitter -->
  <meta name="twitter:card" content="summary_large_image" />
  <meta name="twitter:site" content="@suprdeclarative" />
  <meta name="twitter:title" content="${escape(d['title'])}" />
  <meta name="twitter:description" content="${escape(d['description'])}" />

  <link href="/styles/styles.css" rel="stylesheet">
  <link href="/styles/guide.css" rel="stylesheet">
  <link href="/styles/nest.css" rel="stylesheet">

  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:ital,opsz,wght@0,14..32,100..900;1,14..32,100..900&family=Fira+Mono:wght@400;500;700&display=swap" rel="stylesheet">
  <link href="/styles/navigation.css" rel="stylesheet">
  <script src="/scripts/table-of-contents.js" defer></script>
  <script src="/scripts/section-navigation.js" defer></script>
  ${d['code_examples'] == true ? '''
  <link href="/styles/code-examples.css" rel="stylesheet">
  <script src="/scripts/vendor/prism/prism-flock.min.js" defer></script>
  <script src="/scripts/code-copy-controls.js" defer></script>
  ''' : ''}

</head>

<body class="themed guide-page nest-page">
<site-navbar></site-navbar>
<section class="nest-hero" aria-hidden="true">
  <canvas class="nest-atmosphere" aria-hidden="true"></canvas>
  <div class="nest-stage">
    <img class="nest-centerpiece" src="/images/nest/nest-with-eggs.webp" width="1755" height="896" alt="" fetchpriority="high">
  </div>
</section>
<site-sectionnav></site-sectionnav>

<header class="nest-page-heading">
  <site-brand></site-brand>
</header>

<main>
  <div id="contentColumns">
    <div id="sideMenuColumn">
      <nav id="sideMenu" aria-label="Nest sections">
        <site-sidemenu></site-sidemenu>
      </nav>
    </div>
    <div id="contentColumn">
      <h1>${escape(d['section_title'])}</h1>
      <site-content></site-content>
    </div>
    <aside id="pageContentsColumn" aria-label="Page contents"></aside>
  </div>
</main>

<site-footer></site-footer>
<script src="/scripts/nest-hero.js"></script>
</body>
</html>
''';

String pageMarkup(Map<String, dynamic> d) =>
    '''<!doctype html>

<html lang="en" data-bs-theme="dark">
<head>
  <meta charset="utf-8">
  <title>${escape(d['title'])}</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="description" content="${escape(d['description'])}">

  <link rel="apple-touch-icon" sizes="180x180" href="/images/favicon/apple-touch-icon.png">
  <link rel="icon" type="image/png" sizes="32x32" href="/images/favicon/favicon-32x32.png">
  <link rel="icon" type="image/png" sizes="16x16" href="/images/favicon/favicon-16x16.png">
  <link rel="manifest" href="/images/favicon/site.webmanifest">
  <link rel="mask-icon" href="/images/favicon/safari-pinned-tab.svg" color="#f8217e">
  <link rel="shortcut icon" href="/images/favicon/favicon.ico">
  <meta name="theme-color" content="#0D0912">

  <link rel="canonical" href="https://getflocked.dev${escape(d['url'])}">

  <!-- Open Graph -->
  <meta property="og:title" content="${escape(d['title'])}" />
  <meta property="og:description" content="${escape(d['description'])}" />
  <meta property="og:url" content="https://getflocked.dev${escape(d['url'])}" />
  ${socialMarkup(d)}

  <!-- X/Twitter -->
  <meta name="twitter:card" content="summary_large_image" />
  <meta name="twitter:site" content="@suprdeclarative" />
  <meta name="twitter:title" content="${escape(d['title'])}" />
  <meta name="twitter:description" content="${escape(d['description'])}" />

  <link href="/styles/styles.css" rel="stylesheet">
  <link href="/styles/home.css" rel="stylesheet">
  <link href="/styles/page.css" rel="stylesheet">

  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:ital,opsz,wght@0,14..32,100..900;1,14..32,100..900&display=swap" rel="stylesheet">
  <link href="/styles/navigation.css" rel="stylesheet">

</head>

<body class="home">
  <site-navbar></site-navbar>
  <section class="about-hero" aria-hidden="true">
    <img src="/images/about/creators-in-chairs.webp" width="1920" height="806" alt="" fetchpriority="high">
  </section>
  <main class="about-page">
    <site-content></site-content>
  </main>
  <site-footer></site-footer>
</body>
</html>
''';

String postMarkup(Map<String, dynamic> d) =>
    '''<!doctype html>

<html lang="en" data-bs-theme="dark">
<head>
  <meta charset="utf-8">
  <title>${escape(d['title'])}</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="description" content="${escape(d['description'])}">

  <link rel="apple-touch-icon" sizes="180x180" href="/images/favicon/apple-touch-icon.png">
  <link rel="icon" type="image/png" sizes="32x32" href="/images/favicon/favicon-32x32.png">
  <link rel="icon" type="image/png" sizes="16x16" href="/images/favicon/favicon-16x16.png">
  <link rel="manifest" href="/images/favicon/site.webmanifest">
  <link rel="mask-icon" href="/images/favicon/safari-pinned-tab.svg" color="#f8217e">
  <link rel="shortcut icon" href="/images/favicon/favicon.ico">
  <meta name="theme-color" content="#0d0912">

  <link rel="canonical" href="https://getflocked.dev${escape(d['url'])}">

  <!-- Open Graph -->
  <meta property="og:title" content="${escape(d['title'])}" />
  <meta property="og:description" content="${escape(d['description'])}" />
  <meta property="og:url" content="https://getflocked.dev${escape(d['url'])}" />
  ${socialMarkup(d)}

  <!-- X/Twitter -->
  <meta name="twitter:card" content="summary_large_image" />
  <meta name="twitter:site" content="@suprdeclarative" />
  <meta name="twitter:title" content="${escape(d['title'])}" />
  <meta name="twitter:description" content="${escape(d['description'])}" />

  <link href="/styles/styles.css" rel="stylesheet">
  <link href="/styles/post.css" rel="stylesheet">

  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:ital,opsz,wght@0,14..32,100..900;1,14..32,100..900&family=Fira+Mono:wght@400;500;700&display=swap" rel="stylesheet">
  <link href="/styles/navigation.css" rel="stylesheet">

</head>

<body class="themed post-page">
<site-navbar></site-navbar>
<header>

  <img id="logo" src="/images/flock-logo.png" width="96px" alt="">
  <img id="divider" src="/images/header-hr.png" alt="">
</header>

<main>
  <h1>${escape(d['title'])}</h1>
  <div class="author">
    <img src="${escape((d['author'] as Map)['avatarUrl'])}" class="avatar" alt="" width="42" height="42">
    <div><span class="name">${escape((d['author'] as Map)['name'])}</span> • ${date(d['publishDate'])}</div>
  </div>

  <site-content></site-content>

</main>

<site-footer></site-footer>
</body>
</html>
''';

String redirectMarkup(Map<String, dynamic> d) =>
    '''<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${escape(d['title'])}</title>
  <meta http-equiv="refresh" content="0; url=${escape(d['redirect_url'])}">
  <link rel="canonical" href="${escape(d['canonical_url'] ?? d['redirect_url'])}">
  <meta name="robots" content="noindex">
</head>
<body>
  <h1>${escape(d['title'])}</h1>
  <p>This page has moved. <a href="${escape(d['redirect_url'])}">${escape(d['redirect_label'] ?? 'Continue on GitHub')}</a>.</p>
</body>
</html>
''';

String featuresMarkup(Map<String, dynamic> d) => '''<div class="home-features">
  <section class="feature-overview" id="what-is-it" aria-labelledby="overview-title">
    <div class="feature-intro">
      <h1 id="overview-title">Flock is <span>Flutter++</span></h1>
      <p>Flock is a fork of Flutter. Flock stays up to date with Flutter, adds new features, and fixes bugs on top.</p>
    </div>
    <div class="activity-artwork">
      <img src="/images/features/activity-ribbon-v4-optimized.webp" width="920" height="1039" alt="Flock adds features and fixes bugs on top of Flutter." loading="lazy" decoding="async">
    </div>
  </section>

  <section class="feature-row" id="get-started" aria-labelledby="switch-title">
    <div class="feature-visual switch-visual">
      <div class="config-window">
        <div class="config-toolbar"><span class="window-dots" aria-hidden="true"><i></i><i></i><i></i></span><span>.fvmrc</span></div>
        <pre class="config-code" aria-live="polite"><code>{
  <span class="code-key">"flutter"</span>: <span class="code-value">"master"</span>,
  <span class="config-flock-line"><span class="code-key">"flutterUrl"</span>:
    <span class="code-value">"https://github.com/join-the-flock/flock.git"</span></span>
}</code></pre>
        <div class="config-footer">
        <div class="sdk-picker" role="group" aria-label="Preview FVM configuration">
          <button type="button" data-sdk="flutter" aria-pressed="false">Flutter</button>
          <button type="button" data-sdk="flock" aria-pressed="true">Flock<span>++</span></button>
        </div>
        </div>
      </div>
    </div>
    <div class="feature-copy">
      <h2 id="switch-title">Easy to Switch</h2>
      <p>Move from Flutter, to Flock, and back. All it takes is a change in your Flutter Version Manager (FVM) configuration file.</p>
      <p>Use Flock until you don't need it anymore, and then switch back to Flutter.</p>
      <a class="feature-link" href="/flock/get-started">Get Started <span aria-hidden="true">→</span></a>
    </div>
  </section>

  <section class="feature-row feature-row-reversed" aria-labelledby="branches-title">
    <div class="feature-visual branch-visual">
      <svg class="branch-diagram" viewBox="0 0 700 520" role="img" aria-label="Flock branches receive updates from matching Flutter branches.">
        <defs>
          <linearGradient id="branch-pull-color" x1="0" y1="1" x2="0" y2="0"><stop stop-color="#22d0f2"/><stop offset=".45" stop-color="#b12cd0"/><stop offset="1" stop-color="#ff5ca8"/></linearGradient>
          <linearGradient id="branch-blue-ribbon" x1="0" y1="0" x2="1" y2="0"><stop stop-color="#22d0f2" stop-opacity="0"/><stop offset=".2" stop-color="#159acb"/><stop offset=".5" stop-color="#51dfff"/><stop offset=".8" stop-color="#22d0f2"/><stop offset="1" stop-color="#22d0f2" stop-opacity="0"/></linearGradient>
          <linearGradient id="branch-pink-ribbon" x1="0" y1="0" x2="1" y2="0"><stop stop-color="#b12cd0" stop-opacity="0"/><stop offset=".2" stop-color="#b12cd0"/><stop offset=".52" stop-color="#ff70b6"/><stop offset=".8" stop-color="#f8217e"/><stop offset="1" stop-color="#f8217e" stop-opacity="0"/></linearGradient>
        </defs>
        
        <g class="branch-pair" transform="translate(0 0)" style="--pull-delay: -0s">
          <path class="branch-bloom branch-blue" stroke="url(#branch-blue-ribbon)" d="M-100 165 C170 205 450 90 800 105"/>
          <path class="branch-glow branch-blue" stroke="url(#branch-blue-ribbon)" d="M-100 165 C170 205 450 90 800 105"/>
          <path class="branch-line branch-blue" stroke="url(#branch-blue-ribbon)" d="M-100 165 C170 205 450 90 800 105"/>
          <path class="branch-highlight branch-blue" stroke="url(#branch-blue-ribbon)" d="M-100 165 C170 205 450 90 800 105"/>
          <path class="branch-bloom branch-pink" stroke="url(#branch-pink-ribbon)" d="M-100 87 C170 127 450 12 800 27"/>
          <path class="branch-glow branch-pink" stroke="url(#branch-pink-ribbon)" d="M-100 87 C170 127 450 12 800 27"/>
          <path class="branch-line branch-pink" stroke="url(#branch-pink-ribbon)" d="M-100 87 C170 127 450 12 800 27"/>
          <path class="branch-highlight branch-pink" stroke="url(#branch-pink-ribbon)" d="M-100 87 C170 127 450 12 800 27"/>
          <path class="branch-pull-haze" d="M80.3 171.9 C128.3 171.9 112.0 87.6 160.0 87.6"/>
          <path class="branch-pull" stroke="url(#branch-pull-color)" d="M80.3 171.9 C128.3 171.9 112.0 87.6 160.0 87.6"/>
          <path class="branch-pulse" pathLength="100" d="M80.3 171.9 C128.3 171.9 112.0 87.6 160.0 87.6" style="--connection-delay: -0.0s"/>
          <path class="branch-pull-haze" d="M276.0 150.8 C324.0 150.8 312.1 60.4 360.1 60.4"/>
          <path class="branch-pull" stroke="url(#branch-pull-color)" d="M276.0 150.8 C324.0 150.8 312.1 60.4 360.1 60.4"/>
          <path class="branch-pulse" pathLength="100" d="M276.0 150.8 C324.0 150.8 312.1 60.4 360.1 60.4" style="--connection-delay: -1.3s"/>
          <path class="branch-pull-haze" d="M483.5 121.2 C531.5 121.2 525.7 33.4 573.7 33.4"/>
          <path class="branch-pull" stroke="url(#branch-pull-color)" d="M483.5 121.2 C531.5 121.2 525.7 33.4 573.7 33.4"/>
          <path class="branch-pulse" pathLength="100" d="M483.5 121.2 C531.5 121.2 525.7 33.4 573.7 33.4" style="--connection-delay: -2.6s"/>
        </g>
        
        <g class="branch-pair" transform="translate(0 120)" style="--pull-delay: -1s">
          <path class="branch-bloom branch-blue" stroke="url(#branch-blue-ribbon)" d="M-100 165 C170 205 450 90 800 105"/>
          <path class="branch-glow branch-blue" stroke="url(#branch-blue-ribbon)" d="M-100 165 C170 205 450 90 800 105"/>
          <path class="branch-line branch-blue" stroke="url(#branch-blue-ribbon)" d="M-100 165 C170 205 450 90 800 105"/>
          <path class="branch-highlight branch-blue" stroke="url(#branch-blue-ribbon)" d="M-100 165 C170 205 450 90 800 105"/>
          <path class="branch-bloom branch-pink" stroke="url(#branch-pink-ribbon)" d="M-100 87 C170 127 450 12 800 27"/>
          <path class="branch-glow branch-pink" stroke="url(#branch-pink-ribbon)" d="M-100 87 C170 127 450 12 800 27"/>
          <path class="branch-line branch-pink" stroke="url(#branch-pink-ribbon)" d="M-100 87 C170 127 450 12 800 27"/>
          <path class="branch-highlight branch-pink" stroke="url(#branch-pink-ribbon)" d="M-100 87 C170 127 450 12 800 27"/>
          <path class="branch-pull-haze" d="M80.3 171.9 C128.3 171.9 112.0 87.6 160.0 87.6"/>
          <path class="branch-pull" stroke="url(#branch-pull-color)" d="M80.3 171.9 C128.3 171.9 112.0 87.6 160.0 87.6"/>
          <path class="branch-pulse" pathLength="100" d="M80.3 171.9 C128.3 171.9 112.0 87.6 160.0 87.6" style="--connection-delay: -0.0s"/>
          <path class="branch-pull-haze" d="M276.0 150.8 C324.0 150.8 312.1 60.4 360.1 60.4"/>
          <path class="branch-pull" stroke="url(#branch-pull-color)" d="M276.0 150.8 C324.0 150.8 312.1 60.4 360.1 60.4"/>
          <path class="branch-pulse" pathLength="100" d="M276.0 150.8 C324.0 150.8 312.1 60.4 360.1 60.4" style="--connection-delay: -1.3s"/>
          <path class="branch-pull-haze" d="M483.5 121.2 C531.5 121.2 525.7 33.4 573.7 33.4"/>
          <path class="branch-pull" stroke="url(#branch-pull-color)" d="M483.5 121.2 C531.5 121.2 525.7 33.4 573.7 33.4"/>
          <path class="branch-pulse" pathLength="100" d="M483.5 121.2 C531.5 121.2 525.7 33.4 573.7 33.4" style="--connection-delay: -2.6s"/>
        </g>
        
        <g class="branch-pair" transform="translate(0 240)" style="--pull-delay: -2s">
          <path class="branch-bloom branch-blue" stroke="url(#branch-blue-ribbon)" d="M-100 165 C170 205 450 90 800 105"/>
          <path class="branch-glow branch-blue" stroke="url(#branch-blue-ribbon)" d="M-100 165 C170 205 450 90 800 105"/>
          <path class="branch-line branch-blue" stroke="url(#branch-blue-ribbon)" d="M-100 165 C170 205 450 90 800 105"/>
          <path class="branch-highlight branch-blue" stroke="url(#branch-blue-ribbon)" d="M-100 165 C170 205 450 90 800 105"/>
          <path class="branch-bloom branch-pink" stroke="url(#branch-pink-ribbon)" d="M-100 87 C170 127 450 12 800 27"/>
          <path class="branch-glow branch-pink" stroke="url(#branch-pink-ribbon)" d="M-100 87 C170 127 450 12 800 27"/>
          <path class="branch-line branch-pink" stroke="url(#branch-pink-ribbon)" d="M-100 87 C170 127 450 12 800 27"/>
          <path class="branch-highlight branch-pink" stroke="url(#branch-pink-ribbon)" d="M-100 87 C170 127 450 12 800 27"/>
          <path class="branch-pull-haze" d="M80.3 171.9 C128.3 171.9 112.0 87.6 160.0 87.6"/>
          <path class="branch-pull" stroke="url(#branch-pull-color)" d="M80.3 171.9 C128.3 171.9 112.0 87.6 160.0 87.6"/>
          <path class="branch-pulse" pathLength="100" d="M80.3 171.9 C128.3 171.9 112.0 87.6 160.0 87.6" style="--connection-delay: -0.0s"/>
          <path class="branch-pull-haze" d="M276.0 150.8 C324.0 150.8 312.1 60.4 360.1 60.4"/>
          <path class="branch-pull" stroke="url(#branch-pull-color)" d="M276.0 150.8 C324.0 150.8 312.1 60.4 360.1 60.4"/>
          <path class="branch-pulse" pathLength="100" d="M276.0 150.8 C324.0 150.8 312.1 60.4 360.1 60.4" style="--connection-delay: -1.3s"/>
          <path class="branch-pull-haze" d="M483.5 121.2 C531.5 121.2 525.7 33.4 573.7 33.4"/>
          <path class="branch-pull" stroke="url(#branch-pull-color)" d="M483.5 121.2 C531.5 121.2 525.7 33.4 573.7 33.4"/>
          <path class="branch-pulse" pathLength="100" d="M483.5 121.2 C531.5 121.2 525.7 33.4 573.7 33.4" style="--connection-delay: -2.6s"/>
        </g>
        
      </svg>
    </div>
    <div class="feature-copy">
      <h2 id="branches-title">Mirrored Branches</h2>
      <p>Keep using any Flutter branch. Flock rebases daily on top of Flutter's master, beta, and stable branches.</p>
      <a class="feature-link" href="/flock/get-started">Get Started <span aria-hidden="true">→</span></a>
    </div>
  </section>
</div>
''';

String footerMarkup(Map<String, dynamic> d) => '''<footer>
  <div class="content">
    <div class="team-list-row">
      <!-- ^ used to horizontally center the list items based on intrinsic width -->
      <ul class="team-list">
        <li>
          <a href="https://x.com/suprdeclarative" target="_blank"><img src="/images/team/matt-carroll-192.webp" class="avatar" alt="" width="32" height="32" loading="lazy"> Matt Carroll (@SuprDeclarative)</a>
        </li>
        <li>
          <a href="https://x.com/jezell" target="_blank"><img src="/images/team/jesse-ezell-192.webp" class="avatar" alt="" width="32" height="32" loading="lazy"> Jesse Ezell (@jezell)</a>
        </li>
      </ul>
    </div>
  </div>
</footer>
''';

String socialMarkup(Map<String, dynamic> d) =>
    '''<meta property="og:image" content="https://getflocked.dev/images/flock-social-hero.jpg" />
  <meta property="og:image:type" content="image/jpeg" />
  <meta property="og:image:width" content="1200" />
  <meta property="og:image:height" content="630" />
  <meta property="og:image:alt" content="Fleek embracing pink Flock patch cards above blue Flutter commit cards." />
  <meta name="twitter:image" content="https://getflocked.dev/images/flock-social-hero.jpg" />
  <meta name="twitter:image:alt" content="Fleek embracing pink Flock patch cards above blue Flutter commit cards." />
''';
