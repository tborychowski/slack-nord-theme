# slack-nord-theme
Going full nord


Inspired by the amazing slack night-mode: https://github.com/laCour/slack-night-mode this paints the whole slack window with the nord colours:

[here be screen]


## Installation
1. Close slack
2. Open this file `/Applications/Slack.app/Contents/Resources/app.asar.unpacked/src/static/ssb-interop.js`
    ```sh
    code /Applications/Slack.app/Contents/Resources/app.asar.unpacked/src/static/ssb-interop.js
    ```
3. Append this code:
    ```js
    document.addEventListener('DOMContentLoaded', function() {
     $.ajax({
       url: '[here be css url]',
       success: function(css) {
         $("<style></style>").appendTo('head').html(css);
       }
     });
    });    
    ```
4. Open slack and enjoy the nord darkness!



## Development

#### Slack devtools
```sh
export SLACK_DEVELOPER_MENU=true
open -a /Applications/Slack.app
```

Open dev tools from View menu & inspect stuff.


## Contribution
PRs with screens (before & after) are welcomed!
