<script type="text/javascript" src="http://widgets.twimg.com/j/2/widget.js"></script>
<script type="text/javascript">
    new TWTR.Widget({
      version: 2,
      type: 'profile',
      rpp: 2,
      interval: 3000,
      height: 309,
      width: 210,
      theme: {
        shell: {
          background: 'transparent',
          color: '#3D423C'
        },
        tweets: {
          background: 'transparent',
        }
      },
      features: {
        scrollbar: false,
        loop: false,
        live: true,
        hashtags: true,
        timestamp: false,
        avatars: false,
        behavior: 'default'
      }
    }).render().setUser('mfojtik').start();
</script>
