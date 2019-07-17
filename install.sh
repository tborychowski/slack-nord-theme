#! /usr/bin/env bash
# borrowed from https://github.com/smitt04/slack-dark-theme

REVERT=false

while test $# -gt 0; do
  case "$1" in
    --revert)
      REVERT=true
      shift
      ;;
    *)
      break
      ;;
  esac
done

JS_START="// First make sure the wrapper app is loaded"

JS="
${JS_START}
document.addEventListener('DOMContentLoaded', function() {
  // Fetch our CSS in parallel ahead of time
  const cssPath = 'https://raw.githubusercontent.com/tborychowski/slack-nord-theme/master/slack-nord.css';
  let cssPromise = fetch(cssPath).then((response) => response.text());

  // Insert a style tag into the wrapper view
  cssPromise.then((css) => {
    let s = document.createElement('style');
    s.type = 'text/css';
    s.innerHTML = css;
    document.head.appendChild(s);
  });
});"

OSX_SLACK_RESOURCES_DIR="/Applications/Slack.app/Contents/Resources"
LINUX_SLACK_RESOURCES_DIR="/usr/lib/slack/resources"

if [[ -d $OSX_SLACK_RESOURCES_DIR ]]; then SLACK_RESOURCES_DIR=$OSX_SLACK_RESOURCES_DIR; fi
if [[ -d $LINUX_SLACK_RESOURCES_DIR ]]; then SLACK_RESOURCES_DIR=$LINUX_SLACK_RESOURCES_DIR; fi
if [[ -z $SLACK_RESOURCES_DIR ]]; then
  # Assume on windows if the linux and osx paths failed.
  # Get Windows environment info:
  WIN_HOME_RAW="$(cmd.exe /c "<nul set /p=%UserProfile%" 2>/dev/null)"
  WIN_HOME="$(wslpath $WIN_HOME_RAW)"

  # Find latest version installed
  APP_VER="$(ls -dt ${WIN_HOME}/AppData/Local/slack/app*/)"
  IFS='/', read -a APP_VER_ARR <<< "$APP_VER"

  SLACK_RESOURCES_DIR="${WIN_HOME}/AppData/Local/slack/${APP_VER_ARR[8]}/resources"
fi

SLACK_FILE_PATH="${SLACK_RESOURCES_DIR}/app.asar.unpacked/dist/ssb-interop.bundle.js"

if [ "$REVERT" = true ]; then
echo "Bringing Slack into the light... "
else
echo "Bringing Slack into the darknesss... "
fi

echo ""
echo "This script requires sudo privileges." && echo "You'll need to provide your password."

sudo npx asar extract ${SLACK_RESOURCES_DIR}/app.asar ${SLACK_RESOURCES_DIR}/app.asar.unpacked

if [ "$REVERT" = true ]; then
  sudo sed -i.backup '1,/\/\/# sourceMappingURL=ssb-interop.bundle.js.map/!d' ${SLACK_FILE_PATH}
else
  sudo tee -a "${SLACK_FILE_PATH}" > /dev/null <<< "$JS"
fi

sudo npx asar pack ${SLACK_RESOURCES_DIR}/app.asar.unpacked ${SLACK_RESOURCES_DIR}/app.asar

echo ""
echo "Slack Updated! Refresh or reload slack to see changes"
